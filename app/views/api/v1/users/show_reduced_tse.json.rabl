object @user
cache "Reduced/TSE/#{root_object.rabl_cache_key}"

attributes :id, :name

glue :profile do
  attributes :profile_picture_small_url
end