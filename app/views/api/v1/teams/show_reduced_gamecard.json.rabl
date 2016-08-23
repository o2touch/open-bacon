object @team
cache "GameCard/#{root_object.rabl_cache_key}"

attributes :id, :name

if !root_object.profile.blank?
	glue :profile do
		attributes :colour1, :colour2, :sport, :league_name, :profile_picture_thumb_url, :profile_picture_small_url

		# node(:sport_picture_url) do |profile| 
		# 	# for some reason Rabl isn't finding any view helpers so referencing
		# 	# using the full path. TS
		# 	ActionController::Base.helpers.asset_path(profile.sport_picture_url)
		# end
	end
end