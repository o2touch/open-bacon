object @event
cache "ActivityItem/#{root_object.rabl_cache_key}"

attributes :id, :time, :time_local, :title, :created_at, :game_type, :game_type_string, :time_tbc

if !root_object.team.nil?
	child :team do
		extends "api/v1/teams/show_reduced_gamecard", :view_path => 'app/views'
	end
else
	node :team do
		{}
	end
end

if !root_object.location.nil?
	child :location do
		extends 'api/v1/locations/show', view_path: 'app/views'
	end
end
