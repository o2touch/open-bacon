object @user
cache "ParentCredentials/#{root_object.rabl_cache_key}"

if root_object.junior?
  node :parent_names do |x|
    root_object.parents.each do |x|
  	  x.name
    end
  end
end
