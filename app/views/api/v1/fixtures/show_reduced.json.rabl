object @fixture

attributes :id, :title, :status, :time, :time_local, :time_zone, :home_team_id, :away_team_id
attributes :time_tbc

node :is_competition do |fixture|
  fixture.competition?
end
