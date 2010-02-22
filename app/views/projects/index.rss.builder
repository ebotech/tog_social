xml.instruct! :xml, :version=>"1.0" 
xml.rss(:version=>"2.0"){
  xml.channel{
    xml.title("#{config['plugins.tog_core.site.name']} #{I18n.t('tog_social.projects.site.last_projects')}")
    xml.link projects_url
    xml.description("#{@projects.size} #{I18n.t('tog_social.projects.site.last_projects')}")
    xml.language(I18n.locale.to_s)
      for g in @projects    
          xml.item do
            xml.title(g.name)
            xml.description(g.description)      
            xml.pubDate(g.creation_date(:long))
            xml.author(g.author.profile.full_name)  
            xml.link(project_url(g))               
            xml.guid(g.id)
          end
      end
  }
}
