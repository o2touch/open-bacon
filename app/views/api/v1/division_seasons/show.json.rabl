object @division

attributes :id, :title, :rank, :start_date, :end_date, :age_group, :edit_mode, :launched
attributes :points_categories, :show_standings, :track_results, :scoring_system, :configurable_settings_hash

node :is_competition do |division|
	division.competition?
end

if !root_object.league.nil?
	child :league do
		extends "api/v1/leagues/show_reduced", view_path: "app/views"
	end
end

child :points_adjustments do
	extends "api/v1/points_adjustments/show", view_path: "app/views"
end

child :teams do
	extends "api/v1/teams/show_reduced_gamecard", view_path: "app/views"
end

if !@show_edits.nil? && @show_edits == true
	child :fixtures do
	  extends "api/v1/fixtures/show", view_path: "app/views"
	end
else
	child :fixtures_to_display => :fixtures do
	  extends "api/v1/fixtures/show", view_path: "app/views"
	end
end
