class ProjectsController < ApplicationController

  before_filter :login_required, :only => [:join, :leave]
  before_filter :load_project, :only => [:show, :join, :leave, :members, :accept_invitation, :reject_invitation, :share]

  def index
    @order = params[:order] || 'created_at'
    @page = params[:page] || '1'
    @asc = params[:asc] || 'desc'
    @projects = Project.active.public.paginate  :per_page => 10,
                                            :page => @page,
                                            :order => @order + " " + @asc
    respond_to do |format|
      format.html
      format.rss { render(:layout => false) }
    end
  end

  def search
    @order = params[:order] || 'name'
    @page = params[:page] || '1'
    @search_term = params[:search_term]
    term = '%' + @search_term + '%'
    @asc = params[:asc] || 'asc'
    @projects = Project.active.public.paginate  :per_page => 10,
                                            :conditions => ["(name like ? or description like ?)", term, term],
                                            :page => @page,
                                            :order => @order + " " + @asc
    respond_to do |format|
       format.html { render :template => "projects/index"}
       format.xml  { render :xml => @projects }
    end
  end

  def show
  end

  def members
  end


  def tag
    @tag = params[:tag]
    @projects = Project.active.public.find_tagged_with(@tag)
    respond_to do |format|
      format.html # tag.html.erb
      format.xml  { render :xml => @projects.to_xml }
    end
  end

  def join
    if @project.members.include? current_user
      flash[:notice] = I18n.t("tog_social.projects.site.already_member")
    else
      if @project.pending_members.include? current_user
        flash[:notice] = I18n.t("tog_social.projects.site.request_waiting")
      else
        @project.join(current_user)
        if @project.moderated == true
          ProjectMailer.deliver_join_request(@project, current_user)
          flash[:ok] = I18n.t("tog_social.projects.site.request_received")
        else
          @project.activate_membership(current_user)
          flash[:ok] = I18n.t("tog_social.projects.site.welcome", :name => @project.name)
        end
      end
    end
    redirect_to project_url(@project)
  end

  def leave
    if !@project.members.include?(current_user) && !@project.pending_members.include?(current_user)
      flash[:error] = I18n.t("tog_social.projects.site.not_member")
    else
      if @project.moderators.include?(current_user) && @project.moderators.size == 1
        flash[:error] = I18n.t("tog_social.projects.site.last_moderator")
      else
        @project.leave(current_user)
        #todo: eliminar cuando este claro que sucede si un usuario ya es miembro
        flash[:ok] = I18n.t("tog_social.projects.site.leaved")
      end
    end
    redirect_to member_projects_path
  end
  
  def accept_invitation
    if(@project.accept_invitation(current_user))
      flash[:ok] = I18n.t("tog_social.projects.site.invite.invitation_accepted")
    else
      flash[:error] = I18n.t("tog_social.projects.site.invite.you_are_not_invited")
    end
    redirect_to project_path(@project)
  end
  
  def reject_invitation
    if(@project.leave(current_user))
      flash[:ok] = I18n.t("tog_social.projects.site.invite.invitation_rejected")
    else
      flash[:error] = I18n.t("tog_social.projects.site.invite.you_are_not_invited")
    end
    redirect_to project_path(@project)
  end
  
  protected
    def load_project
      #TODO be more specific with this error control
      begin
        @project = Project.find(params[:id])
        raise I18n.t("tog_social.site.projects.unactive") unless @project.active?
      rescue
        flash[:error] = I18n.t("tog_social.projects.site.not_found")
        redirect_to projects_path
      end
    end

    def send_message_to_moderators(project, user, subject, body)
      project.moderators.each do |moderator|
        message = Message.new(
          :from     => user,
          :to       => moderator,
          :subject  => subject,
          :content  => body)
        message.dispatch!
      end
    end
end
