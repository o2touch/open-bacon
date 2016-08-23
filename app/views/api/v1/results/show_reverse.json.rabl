# This file was created as the front end is displaying all scores as though the home team won, when shown on events
object @result

attributes :id
attributes :home_score => :away_score, :away_score => :home_score, :home_final_score_str => :away_final_score_str, :away_final_score_str => :home_final_score_str
attributes :draw? => :draw, :home_team_won? => :away_team_won, :away_team_won? => :home_team_won
