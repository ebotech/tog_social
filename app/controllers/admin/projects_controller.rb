class Admin::ProjectsController < Admin::BaseController

  def index
    @order = params[:order] || 'name'
    @page = params[:page] || '1'
    @projects = Project.paginate :per_page => 20,
                             :page => @page,
                             :order => "#{@order} ASC"
  end

  def edit
    @project = Project.find(params[:id])
  end
  
  def update
    @project = Project.find(params[:id])    
    @project.update_attributes!(params[:project])
    @project.save
    flash[:ok] =  I18n.t("tog_social.projects.admin.updated", :name => @project.name) 
    redirect_to edit_admin_project_path(@project)
  end  

  def destroy
    @project = Project.find(params[:id])
    @project.destroy
    respond_to do |wants|
      wants.html do
        flash[:ok]= I18n.t("tog_social.projects.admin.deleted")
        redirect_to admin_projects_path
      end
    end
  end

  def activate
    @project = Project.find(params[:id])
    @project.activate!
    respond_to do |wants|
      if @project.activate!
        wants.html do
          render :text => "<span>#{I18n.t("tog_social.projects.admin.activated")}</span>"
        end
      end
    end
  end

end
