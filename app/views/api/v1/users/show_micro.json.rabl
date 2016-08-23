object @user
cache "Micro/v1/#{root_object.rabl_cache_key}"

attributes :id, :name, :username
attributes junior?: :junior, parent?: :parent

node :type do |user|
	"demo" if user.type == "DemoUser"
end

if !root_object.profile.blank?
  glue :profile do
    attributes :profile_picture_thumb_url, :profile_picture_small_url
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
    group.cached_team_roles.map do |team_role|
      partial 'api/v1/poly_roles/show', object: team_role, root:false
    end
  end
else
  node :team_roles do
    []
  end
end