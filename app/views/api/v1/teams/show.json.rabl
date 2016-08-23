object @team
cache "#{root_object.rabl_cache_key}"

attributes :id, :faft_id, :name, :created_by_id, :demo_mode, :uuid, :tenant_id, :club_id

if !root_object.profile.blank?
	glue :profile do
		attributes :age_group, :colour1, :colour2, :league_name, :sport, :profile_picture_thumb_url
		attributes :profile_picture_small_url, :profile_picture_medium_url, :profile_picture_large_url

		# node(:sport_picture_url) do |profile| 
		# 	# for some reason Rabl isn't finding any view helpers so referencing
		# 	# using the full path. TS
		# 	ActionController::Base.helpers.asset_path(profile.sport_picture_url)
		# end
	end
end

if !root_object.club.nil?
	child(:club) { attributes :id, :name }
end

# hmm copied this from another file, but sure this is wrong?! TS
node :team_division_season_roles do |team|
	team.team_division_season_roles.map do |tdsr|
		partial 'api/v1/team_division_season_roles/show', object: tdsr, root: false
	end
end

# WHAT THE FUCK??! We shoul not be sending this shit... TS
if root_object.divisions.count == 1
	child root_object.divisions.first do
		extends "api/v1/division_seasons/show_reduced", view_path: 'app/views'
	end
	child root_object.divisions.first.league do
		extends "api/v1/leagues/show_reduced", view_path: 'app/views'
	end
end

# tenanted attrs
extra_fields = root_object.config.event_extra_fields || []
node(:event_extra_fields) { extra_fields }
comp_fields = root_object.config.event_compulsory_fields || []
node(:event_compulsory_fields) { comp_fields }
