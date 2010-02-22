# Add your custom routes here.  If in config/routes.rb you would
# add <tt>map.resources</tt>, here you would add just <tt>resources</tt>

resources :profiles

resources :streams, :only => [:index, :show], :member => {:network => :get}

with_options(:controller => 'projects') do |project|
  project.tag_projects       '/projects/tag/:tag',                         :action => 'tag'
end
resources :projects, :collection => { :search => :get }, :member => { :join => :get, :leave => :get, :accept_invitation => :get, :reject_invitation => :get }

with_options(:controller => 'groups') do |group|
  group.tag_groups       '/groups/tag/:tag',                         :action => 'tag'
end
resources :groups, :collection => { :search => :get }, :member => { :join => :get, :leave => :get, :accept_invitation => :get, :reject_invitation => :get }

namespace(:member) do |member|
  member.resources :profiles
  member.resources :projects
  member.with_options(:controller => 'projects') do |project|
    project.project_pending_members '/:id/members/pending',         :action => 'pending_members'
    project.project_accept_member   '/:id/members/:user_id/accept', :action => 'accept_member'
    project.project_reject_member   '/:id/members/:user_id/reject', :action => 'reject_member'
    project.project_invite          '/project/invite',                :action => 'invite'
  end
  member.resources :groups
  member.with_options(:controller => 'groups') do |group|
    group.group_pending_members '/:id/members/pending',         :action => 'pending_members'
    group.group_accept_member   '/:id/members/:user_id/accept', :action => 'accept_member'
    group.group_reject_member   '/:id/members/:user_id/reject', :action => 'reject_member'
    group.group_invite          '/group/invite',                :action => 'invite'
  end
  member.with_options(:controller => 'friendships') do |friendship|
    friendship.add_friend     '/friend/:friend_id/add',     :action => 'add_friend'
    friendship.confirm_friend '/friend/:friend_id/confirm', :action => 'confirm_friend'
    friendship.follow_user    '/follow/:friend_id',         :action => 'follow'
    friendship.unfollow_user  '/unfollow/:friend_id',       :action => 'unfollow'
  end
  member.with_options(:controller => 'sharings') do |sharing|
    sharing.share '/sharings/share/:group_id/:shareable_type/:shareable_id', :action => 'create', :conditions => { :method => :post }    
    sharing.new_sharing '/sharings/:shareable_type/:shareable_id/new', :action => 'new'
    sharing.sharings '/sharings', :action => 'index'
    sharing.destroy_sharing '/sharings/:group_id/:id', :action => 'destroy', :conditions => { :method => :delete }      
    sharing.destroy_sharing '/sharings/:project_id/:id', :action => 'destroy', :conditions => { :method => :delete }      
#    sharing.destroy_sharing '/group/:id/remove/:shareable_type/:shareable_id', :action => 'destroy', :method => :delete  
  end
end

namespace(:admin) do |admin|
  admin.resources :projects, :member => { :activate => :post}
  admin.resources :groups, :member => { :activate => :post}
end

# => oauth support
resources :oauth_clients
authorize     '/oauth/authorize',     :controller=>'oauth', :action=>'authorize'
request_token '/oauth/request_token', :controller=>'oauth', :action=>'request_token'
access_token  '/oauth/access_token',  :controller=>'oauth', :action=>'access_token'
test_request  '/oauth/test_request',  :controller=>'oauth', :action=>'test_request'

x1 '/oauth_test',     :controller=>'oauth_test', :action=>'test'
x2 '/oauth_callback', :controller=>'oauth_test', :action=>'callback'
# => oauth support
