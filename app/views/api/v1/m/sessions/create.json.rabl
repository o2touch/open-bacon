object @user

attributes :id
attributes :authentication_token => :auth_token
attributes :generated_password, :if => lambda { |u| !u.generated_password.nil? }

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

if !root_object.profile.blank?
  glue :profile do
    attributes :profile_picture_small_url
  end
else
  node :profile do
    {}
  end
end