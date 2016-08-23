object @event_result

attributes :id

node :home_score do
  root_object.score_for
end

node :away_score do
  root_object.score_against
end

node :home_final_score_str do
  root_object.score_for
end

node :away_final_score_str do
  root_object.score_against
end

node :draw do
  root_object.draw?
end

node :home_team_won do
  root_object.won?
end

node :away_team_won do
  root_object.lost?
end
