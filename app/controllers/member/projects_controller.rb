class Member::ProjectsController < Member::BaseController

  before_filter :find_project, :except => [:index, :new, :create]
  before_filter :check_moderator, :except => [:index, :new, :create, :invite, :accept_invitation, :reject_invitation]

  def index
    @moderator_memberships = current_user.moderator_memberships
    @plain_memberships = current_user.plain_memberships
  end

  def create
    @project = Project.new(params[:project])
    @project.author = current_user
    @project.save


    if @project.errors.empty?

      @project.join(current_user, true)
      #    @project.activate_membership(current_user)

      if current_user.admin == true || Tog::Config['plugins.tog_social.project.moderation.creation'] != true
         @project.activate!
         flash[:ok] = I18n.t("tog_social.projects.member.created")
         redirect_to project_path(@project)
      else

        admins = User.find_all_by_admin(true)        
        admins.each do |admin|
          Message.new(
            :from => current_user,
            :to   => admin,
            :subject => I18n.t("tog_social.projects.member.mail.activation_request.subject", :project_name => @project.name),
            :content => I18n.t("tog_social.projects.member.mail.activation_request.content", 
                               :user_name   => current_user.profile.full_name, 
                               :project_name => @project.name, 
                               :activation_url => edit_admin_project_url(@project)) 
          ).dispatch!     
        end

        flash[:warning] = I18n.t("tog_social.projects.member.pending")
        redirect_to projects_path
      end
    else
      render :action => 'new'
    end

  end

  def update
    @project.update_attributes!(params[:project])
    @project.tag_list = params[:project][:tag_list]
    @project.save
    flash[:ok] =  I18n.t("tog_social.projects.member.updated", :name => @project.name) 
    redirect_to project_path(@project)
  end

  def reject_member
    user = User.find(params[:user_id])
    if !user
      flash[:error] = I18n.t("tog_social.projects.member.user_doesnot_exists")
      redirect_to pending_members_paths(@project)
      return
    end
    @project.leave(user)
    if @project.membership_of(user)
      ProjectMailer.deliver_reject_join_request(@project, current_user, user)
      flash[:ok] = I18n.t("tog_social.projects.member.user_rejected", :name => user.profile.full_name) 
    else
      flash[:error] = I18n.t("tog_social.projects.member.error") 
    end
    redirect_to member_project_pending_members_url(@project)
  end

  def accept_member
    user = User.find(params[:user_id])
    if !user
      flash[:error] = I18n.t("tog_social.projects.member.user_doesnot_exists")
      redirect_to pending_members_paths(@project)
      return
    end
    @project.activate_membership(user)
    if @project.members.include? user
      ProjectMailer.deliver_accept_join_request(@project, current_user, user)
      flash[:ok] = I18n.t("tog_social.projects.member.user_accepted", :name => user.profile.full_name)
    else
      flash[:error] = I18n.t("tog_social.projects.member.error") 
    end
    redirect_to member_project_pending_members_url(@project)
  end

  def invite
    @project = Project.find(params[:membership][:project_id])
    user = User.find(params[:membership][:user_id])
    if @project.can_invite?(current_user)
      if @project.members.include? user
        flash[:notice] = I18n.t("tog_social.projects.site.already_member")
      else
        if @project.invited_members.include? user
          flash[:error] = I18n.t("tog_social.projects.site.invite.already_invited")
        else
          @project.invite(user)
          @message = Message.new(
          :from => current_user,
          :to => user,
          :subject => I18n.t("tog_social.projects.member.mail.invitation.subject", :project=>@project.name),
          :content => render_to_string(:partial => 'invite_mail', :locals =>{:project=>@project})
          )
          @message.dispatch!
          flash[:ok] = I18n.t("tog_social.projects.site.invite.invited")
        end
      end
    else
      flash[:error] = flash[:error] = I18n.t("tog_social.projects.site.invite.you_could_not_invite")
    end
    redirect_to profile_path(user.profile)
  end

  protected


  def find_project
    @project = Project.find(params[:id]) if params[:id]
  end

  def check_moderator
    unless @project.moderators.include? current_user
      flash[:error] = I18n.t("tog_social.projects.member.not_moderator") 
      redirect_to project_path(@project)
    end
  end

end
