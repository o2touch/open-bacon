object @user
cache "Reduced/Private/#{root_object.rabl_cache_key}"

attributes :id, :name
#attributes junior?: :junior, parent?: :parent

# node :type do |user|
#   "demo" if user.type == "DemoUser"
# end

if !root_object.profile.blank?
  glue :profile do
    #attributes :bio, :profile_picture_thumb_url, :profile_picture_small_url, :profile_picture_medium_url, :profile_picture_large_url
    attributes :profile_picture_thumb_url, :profile_picture_small_url, :profile_picture_medium_url, :profile_picture_large_url
  end
else
  node :profile do
    {"blank" => true}
  end
end
