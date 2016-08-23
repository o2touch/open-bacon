object @user
cache "ActivityItem/#{root_object.rabl_cache_key}"

attributes :id, :name, :email, :mobile_number, :username

if !root_object.profile.blank?
  glue :profile do
    attributes :profile_picture_thumb_url, :profile_picture_small_url
  end
else
  node :profile do
    {}
  end
end
