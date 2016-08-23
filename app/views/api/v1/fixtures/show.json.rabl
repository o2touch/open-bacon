object @fixture

attributes :id, :title, :status, :time, :time_local, :time_zone, :home_event_id, :away_event_id, :home_team_id, :away_team_id, :edited
attributes :is_deletable? => :is_deletable, :home_team_editable? => :home_team_editable, :away_team_editable? => :away_team_editable
attributes :time_tbc

node :is_competition do |fixture|
  fixture.competition?
end

if !root_object.location.nil?
	child :location do
		extends 'api/v1/locations/show', view_path: 'app/views'
	end
end

# teams
if !root_object.home_team.nil?
	child :home_team => :home_team do
		extends 'api/v1/teams/show_micro', view_path: 'app/views'
	end
end	
if !root_object.away_team.nil?
	child :away_team => :away_team do
		extends 'api/v1/teams/show_micro', view_path: 'app/views'
	end
end	

if !root_object.points.nil?
	child :points => :points do
		extends 'api/v1/points/show', view_path: 'app/views'
	end
end

if !root_object.result.nil?
	child :result => :result do
		extends 'api/v1/results/show', view_path: 'app/views'
	end
end