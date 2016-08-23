object @club

attributes :id, :name

if !root_object.profile.blank?
	glue :profile do
		attributes :colour1, :colour2, :sport, :profile_picture_thumb_url
		attributes :profile_picture_small_url, :profile_picture_medium_url, :profile_picture_large_url

		# node(:sport_picture_url) do |profile| 
		# 	# for some reason Rabl isn't finding any view helpers so referencing
		# 	# using the full path. TS
		# 	ActionController::Base.helpers.asset_path(profile.sport_picture_url)
		# end
	end
end

if !root_object.location.nil?
	child :location do
		extends 'api/v1/locations/show', view_path: 'app/views'
	end
end