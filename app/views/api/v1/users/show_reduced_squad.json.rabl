object @user
cache "Squad/v1/#{root_object.rabl_cache_key}"

attributes :id, :name
attributes junior?: :junior, parent?: :parent

node :type do |user|
	"demo" if user.type == "DemoUser"
end

if !root_object.profile.blank?
  glue :profile do
    attributes :bio, :profile_picture_thumb_url, :profile_picture_small_url, :profile_picture_medium_url, :profile_picture_large_url
  end
else
  node :profile do
    {}
  end
end

if root_object.junior? 
  node :parent_ids do |user|
    user.parent_ids
  end
end

if !root_object.cached_team_roles.blank?
	node :team_roles do |group|
    partial 'api/v1/poly_roles/index', object: group.team_roles, root: false
  end
else
	node :team_roles do
		[]
	end
end

if !root_object.cached_roles.blank?
  node :roles do |group|
    group.cached_roles.map do |role|
      partial "api/v1/roles/show", object: role, root:false
    end
  end
else
  node :roles do
    []
  end
end
