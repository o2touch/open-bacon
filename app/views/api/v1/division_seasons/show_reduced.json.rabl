object @division

attributes :id, :faft_id, :title

node :is_competition do |division|
  division.competition?
end
