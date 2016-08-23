module Metrics
  class TeamAnalysis
    class << self

      def active_between(week_begin, week_end, year=2013, team_ids=nil, clear_cache=false)
        results = {}

        for i in week_begin..week_end
          key = Date.commercial(year,i,1).strftime("%Y-%V")
          results[key] = self.weekly_active(i, year, team_ids, clear_cache)
        end

        return results
      end

      def weekly_active(week, year=2013, in_team_ids=nil, clear_cache=false)
        wk_begin = Date.commercial(year, week, 1)
        wk_end = Date.commercial(year, week, 7).end_of_day
        
        # Only want teams with more than (4 players)
        if in_team_ids.nil?
          in_team_ids = self.teams_with_more_than
        else
          in_team_ids = self.teams_with_more_than_from_ids(in_team_ids)
        end
        return [] if in_team_ids.empty?
        
        teams = []
        (0..6).each do |day_of_week|
          curr_day = wk_begin + day_of_week

          results = self.daily_active(curr_day, in_team_ids, clear_cache)
          results.each do |row|
            teams << row if !teams.include?(row)
          end
        end

        return teams
      end

      def daily_active(date, in_team_ids, clear_cache)
        teams = []
        clear_cache = true if (date >= Date.today || clear_cache)
        results = Metrics::Tools.execute_cached_query(Metrics::Query::active_teams_query(date.strftime("%Y-%m-%d"), in_team_ids), clear_cache)
        results.each do |row|
          teams << row[0] if !teams.include?(row[0])
        end
        teams
      end

      def new_between(start_week, end_week, in_team_ids=nil, clear_cache=false)
        weekly_results = []

        for i in start_week..end_week
          key = i.strftime("%Y-%V")
          weekly_results << self.new_in_week(i, in_team_ids, clear_cache)
        end

        return weekly_results.flatten
      end

      def new_in_week(wk_start_date, in_team_ids, clear_cache=false)
        wk_begin = wk_start_date.at_beginning_of_week
        wk_end = wk_start_date.at_end_of_week
        teams = []

        (0..6).each do |day_of_week|
          curr_day = wk_begin + day_of_week
          date_str = curr_day.strftime("%Y-%m-%d")

          clear_cache = true if (curr_day >= Date.today || clear_cache)

          results = Metrics::Tools.execute_cached_query(Metrics::Query.new_teams_query(date_str, in_team_ids), clear_cache)
          results.each do |row|
            teams << row[0] if !teams.include?(row[0])
          end
        end

        return teams
      end

      def weekly_churned(week, year=2013, in_team_ids=nil, clear_cache=false)
        last_active_team_ids = self.weekly_active(week - 1, year, in_team_ids, clear_cache)
        current_active_team_ids = self.weekly_active(week, year, in_team_ids, clear_cache)

        return last_active_team_ids - current_active_team_ids
      end

      def weekly_activated(week, year=2013, in_team_ids=nil, clear_cache=false)
        last_active_team_ids = self.weekly_active(week - 1, year, in_team_ids, clear_cache)
        current_active_team_ids = self.weekly_active(week, year, in_team_ids, clear_cache)

        return current_active_team_ids - last_active_team_ids
      end

      def number_members(type, team_id, day)
        Metrics::Tools.execute_cached_query(Metrics::Query.number_members(type, team_id, day), true)      
      end

      def teams_with_more_than
        Metrics::Tools.execute_cached_query(Metrics::Query.teams_with_more_than, true)      
      end

      def teams_with_more_than_from_ids(in_team_ids)
        Metrics::Tools.execute_cached_query(Metrics::Query.teams_with_more_than_from_ids_query(in_team_ids), true)      
      end

      def users_in_divisions(divisions)
        Metrics::Tools.execute_cached_query(Metrics::Query.users_in_divisions_query(divisions), true)
      end

      def teams_in_divisions(divisions)
        Metrics::Tools.execute_cached_query(Metrics::Query.teams_in_divisions_query(divisions), true)
      end

      def adult_team_ids
        Metrics::Tools.execute_cached_query(Metrics::Query.adult_teams_query(), true)
      end

      def junior_team_ids
        Metrics::Tools.execute_cached_query(Metrics::Query.junior_teams_query(), true)
      end

      def league_team_ids
        Metrics::Tools.execute_cached_query(Metrics::Query.league_teams_query(), true)
      end

      def tenant_team_ids(tenant_id)
        Metrics::Tools.execute_cached_query(Metrics::Query.tenant_teams_query(tenant_id), true)
      end

    end
	end
end