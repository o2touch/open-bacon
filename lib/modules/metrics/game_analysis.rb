module Metrics
  class GameAnalysis
    class << self

      def daily_game_count_between(start_date, end_date, clear_cache=false)

        results = []

        (start_date..end_date).each do |day|
          result = {}
          result[:day] = day.strftime("%Y-%m-%d")
          result[:faft] = self.games_in_day(day, self.faft_team_ids, clear_cache).size
          result[:league] = self.games_in_day(day, self.league_team_ids, clear_cache).size
          result[:total] = self.games_in_day(day, nil, clear_cache).size
          results << result
        end

        return results
      end

      def games_in_day(day, for_teams_ids=nil, clear_cache=false)

        start_date_str = day.strftime("%Y-%m-%d")

        data = []

        results = Metrics::Tools.execute_cached_query(Metrics::Query.games_in_day(start_date_str, for_teams_ids), clear_cache)
        results.each do |row|
          data << row[0] if !data.include?(row[0])
        end

        return data
      end


      def league_team_ids
        Metrics::Tools.execute_cached_query(Metrics::Query.league_teams_query, true)
      end

      def faft_team_ids
        Metrics::Tools.execute_cached_query(Metrics::Query.faft_teams_query, true)
      end

    end
	end
end