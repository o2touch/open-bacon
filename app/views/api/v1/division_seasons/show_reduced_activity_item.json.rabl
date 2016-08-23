object @division

attributes :id, :title

node :is_competition do |division|
  division.competition?
end

child :league do
  extends "api/v1/leagues/show_reduced_activity_item", view_path: "app/views"
end
