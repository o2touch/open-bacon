class DivisionPresenter < Draper::Decorator

  def standings_cache_key
    # TODO: wonder if we should just eg. touch div when updating a fixture,
    #        in situations like this, instead of pinging db for a few different stats...? TS
    "division/#{object.id}-#{object.updated_at}/standings" # shit that used to be checked here, now does div.touch
  end

  def form_cache_key
    "division/#{object.id}-#{object.updated_at}/form" # shit that used to be checked here, now does div.touch
  end

  def team_registration_enabled?
    return (!object.config.division_joinable.nil? && object.config.division_joinable==true)
  end

  def registration_open?
    return (!object.config.application_open.nil? && object.config.application_open==true)
  end

  # Calculate Standings Position
  def standings_position(team)
    position = standings[:series].index(team.id).nil? ? 0 : standings[:series].index(team.id) + 1
    position.ordinalize.to_s
  end

  def games_played(team)
    return 0 if standings[:data][team.id].nil?
    standings[:data][team.id][:played]
  end

  def games_won(team)
    return 0 if standings[:data][team.id].nil?
    standings[:data][team.id][:won]
  end

  def form_guide(team)
    Rails.cache.fetch(form_cache_key) do
      str = ""
      object.past_fixtures.reverse.each do |fixture|
        next unless fixture.home_team_id == team.id || fixture.away_team_id == team.id
        result = ResultPresenter.new(fixture.result)
        str += result.result_as_letter_for_team(team)
        return str if str.length >= 5
      end
      str.gsub!(/[^WLD-]/, '')
      str = "-" if str.blank?
      str
    end
  end

  # HACK: We only want to display teams who have played a game in a division
  # This is a hack because mitoo data has redundant teams in divisions
  def teams
    standings_data = self.standings
    display_teams = []

    object.teams.each do |t|
      display_teams << t if standings_data[:data].key?(t.id) && standings_data[:data][t.id][:played] > 0
    end

    display_teams
  end

  def show_standings? 
  	object.show_standings && !self.standings.empty? && !self.standings[:data].empty? 
  end

  def standings
    Rails.cache.fetch(standings_cache_key) do
	    data = {}
	    standings = {} 
	    
	    object.teams.each do |t|
	      standings[t.id] = {
	        won:    0,
	        lost:   0,
	        drawn:  0,
	        played: 0,
	        points: 0,
	        goals_for: 0,
	        goals_against: 0
	      }
	    end

	    object.fixtures.each do |fixture|
	      next if fixture.points.nil? || fixture.result.nil?

	      # save some typing
	      ht = fixture.home_team
	      at = fixture.away_team
	      r = fixture.result
	      p = fixture.points

	      # ensure that one of the teams hasn't left the division, or something...
	      next unless object.teams.include?(ht) && object.teams.include?(at)

	      # home team
	      if !fixture.home_team.nil?
	        standings[ht.id][:won] += 1 if r.home_team_won?
	        standings[ht.id][:lost] += 1 if r.away_team_won?
	        standings[ht.id][:drawn] += 1 if r.draw?
	        standings[ht.id][:played] += 1
	        standings[ht.id][:points] += p.total_home_points
	        standings[ht.id][:goals_for] += r.home_final_score_str.to_i
	        standings[ht.id][:goals_against] += r.away_final_score_str.to_i
	      end

	      # away team
	      if !fixture.away_team.nil?
	        standings[at.id][:won] += 1 if r.away_team_won?
	        standings[at.id][:lost] += 1 if r.home_team_won?
	        standings[at.id][:drawn] += 1 if r.draw?
	        standings[at.id][:played] += 1
	        standings[at.id][:points] += p.total_away_points
	        standings[at.id][:goals_for] += r.away_final_score_str.to_i
	        standings[at.id][:goals_against] += r.home_final_score_str.to_i
	      end
	    end

	    object.points_adjustments.each do |pa|
	      next unless pa.division_season == self # could be a different div.
	      next unless standings.has_key? pa.team_id # in case the team has left the div

	      standings[pa.team_id][:won] += pa.adjustment if pa.adjustment_type == PointsAdjustmentTypeEnum::WON
	      standings[pa.team_id][:lost] += pa.adjustment if pa.adjustment_type == PointsAdjustmentTypeEnum::LOST
	      standings[pa.team_id][:drawn] += pa.adjustment if pa.adjustment_type == PointsAdjustmentTypeEnum::DRAWN
	      standings[pa.team_id][:played] += pa.adjustment if pa.adjustment_type == PointsAdjustmentTypeEnum::PLAYED
	      standings[pa.team_id][:points] += pa.adjustment if pa.adjustment_type == PointsAdjustmentTypeEnum::POINTS
	      standings[pa.team_id][:goals_for] += pa.adjustment if pa.adjustment_type == PointsAdjustmentTypeEnum::GOALS_FOR
	      standings[pa.team_id][:goals_against] += pa.adjustment if pa.adjustment_type == PointsAdjustmentTypeEnum::GOALS_AGAINST
	      # ignoring goals for/against, as we don't currently display that...
	    end

	    data[:series] = standings.sort_by do |_, v|
	   		# TODO: ensure point are received for home/away walkover
	   		points_s = v[:points].to_s
	   		g_diff_s = (1000 + (v[:goals_for] - v[:goals_against])).to_s
	   		g_for_s = v[:goals_for].to_s

	   		zeros = "0"*(4-g_diff_s.length)
	   		g_diff_s = "#{zeros}#{g_diff_s}"

	   		zeros = "0"*(4-g_for_s.length)
	   		g_for_s = "#{zeros}#{g_for_s}"

	   		"#{points_s}#{g_diff_s}#{g_for_s}".to_i
	    end.reverse.map{ |k, v| k }

	    standings.each do |_, v|
	    	v.delete :goals_for
	    	v.delete :goals_against
	    end

	    data[:data] = standings
	    data
    end
	end
end