object @user
cache "#{root_object.rabl_cache_key}#{root_object.fb_connected?}"

attributes :id, :name, :email, :time_zone, :mobile_number, :country, :created_at, :username
attributes junior?: :junior, parent?: :parent
attributes needs_password?: :needs_password, :if => lambda { |m| m.needs_password? }

# this is a pile of shit, but not going to do anything more scalable, until required.
# (ie. doesn't scale, and is being sent as a result of a session create request,
#  should reqlly be a separate request for this information (or send all user info
#  every time we start a session.
node(:o2_fields_complete) do
	!root_object.tenanted_attrs.nil? && root_object.tenanted_attrs.has_key?(:player_history)
end
node(:needs_o2_fields) do
  root_object.needs_o2_fields?
end

node :type do |user|
	"demo" if user.type == "DemoUser"
end

if !root_object.profile.blank?
	glue :profile do
	  attributes :bio, :profile_picture_thumb_url, :profile_picture_small_url
	  attributes :profile_picture_medium_url, :profile_picture_large_url, :dob, :gender

	  if !root_object.location.nil?
			child :location do 
				extends 'api/v1/locations/show'
			end
	  end
	end
else
	node :profile do
		{"blank" => true}
	end
end

node :tenant_id do |user|
	LandLord.new(user).tenant.id
end

if root_object.junior? 
	node :parent_ids do |user|
    user.parent_ids
  end
end

node :child_ids do |user|
	user.child_ids
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

if !root_object.league_roles.blank?
	node :league_roles do |group|
    partial 'api/v1/poly_roles/index', object: group.league_roles, root: false
  end
else
	node :league_roles do
		[]
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

if !root_object.cached_tenant_roles.blank?
  node :tenant_roles do |group|
    partial 'api/v1/poly_roles/index', object: group.tenant_roles, root: false
  end
else
  node :tenant_roles do
    []
  end
end

node(:fb_connected, :if => lambda { |m| m==root_object }) do |m|
  m.fb_connected?
end