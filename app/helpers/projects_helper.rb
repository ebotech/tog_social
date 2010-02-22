module ProjectsHelper

  def tag_cloud_projects(classes)
    tags = Project.tag_counts(:conditions => "state= 'active' and private = 0")
    return if tags.empty?
    max_count = tags.sort_by(&:count).last.count.to_f
    tags.each do |tag|
      index = ((tag.count / max_count) * (classes.size - 1)).round
      yield tag, classes[index]
    end
  end

  def image_for_project(project, size, options={})
    return if !project
    if project.image?
      photo_url = project.image.url(size)
      options.merge!(:alt => "Photo for project: #{project.name}")
      return image_tag(photo_url, options) if photo_url
    else
      return image_tag("/tog_social/images/#{config["plugins.tog_social.project.image.default"]}", options)
    end
  end


  def last_projects(limit=3)
    Project.find(:all,:conditions => ["state= ? and private = ?", 'active', false],:order => "created_at desc", :limit => limit)
  end


  def i_am_member_of(project)
    return project.members.include?(current_user)
  end
  def i_am_moderator_of(project)
    return project.moderators.include?(current_user)
  end

end
