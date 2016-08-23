module Metrics
  class RewardsAndRecognitionAnalysis
    class << self

      def get_events_with_checkins_for_team(team_id, start_date, end_date, in_user_ids=nil)

        start_date_str = start_date.strftime("%Y-%m-%d")
        end_date_str = end_date.strftime("%Y-%m-%d")

        results = Metrics::Tools.execute_query(Metrics::Query::get_events_with_checkins_for_team(team_id, start_date_str, end_date_str, in_user_ids))

        return results
      end

      def get_checkins_for_team(team_id, start_date, end_date, in_user_ids=nil)

        start_date_str = start_date.strftime("%Y-%m-%d")
        end_date_str = end_date.strftime("%Y-%m-%d")

        results = Metrics::Tools.execute_query(Metrics::Query::get_checkins_for_team(team_id, start_date_str, end_date_str, in_user_ids))

        return results
      end

      def get_new_players_for_team(team_id, start_date, end_date)
        start_date_str = start_date.strftime("%Y-%m-%d")
        end_date_str = end_date.strftime("%Y-%m-%d")

        results = Metrics::Tools.execute_query(Metrics::Query::get_new_players_for_team(team_id, start_date_str, end_date_str))

        return results
      end

      def calcuate_retention(team_id, start_date, end_date)
        start_date_str = start_date.strftime("%Y-%m-%d")
        end_date_str = end_date.strftime("%Y-%m-%d")

        # Existing Players
        ep_retention = 0

        sessions_in_month = Metrics::Tools.execute_query(Metrics::Query::get_events_for_team(team_id, start_date_str, end_date_str))
        existing_players = Metrics::Tools.execute_query(Metrics::Query::get_existing_players_for_team(team_id, start_date_str, end_date_str))
        
        if existing_players.size > 0
          existing_players_ids = existing_players.map {|u| u[0]}
          ep_max_returned_attendance = existing_players.size * sessions_in_month.size
          ep_actual_returned_attendance = self.get_checkins_for_team(team_id, start_date, end_date, existing_players_ids).size

          ep_retention = ep_actual_returned_attendance / ep_max_returned_attendance if ep_max_returned_attendance > 0
        end

        # New Players
        new_players_ids = self.get_new_players_for_team(team_id, start_date, end_date)
        np_retention = []
        new_players = User.find(new_players_ids)
        new_players.each do |u|
          created_at_str = u.created_at.strftime("%Y-%m-%d")
          possible_sessions = Metrics::Tools.execute_query(Metrics::Query::get_events_for_team(team_id, created_at_str, end_date_str))
          attendance = self.get_checkins_for_team(team_id, start_date, end_date, [u.id]).size
          
          if possible_sessions.size > 1
            np_retention << attendance / (possible_sessions.size - 1)
          else
            np_retention << 0
          end
        end

        total_retention = ep_retention

        if np_retention.size > 0
          avg_np_retention = np_retention.sum / np_retention.size.to_f
          total_retention = (ep_retention + avg_np_retention) / 2
        end
        
        return total_retention * 100
      end


      def get_points_for_month(start_date=Date.new, end_date=nil, region=nil)

        start_date = start_date.at_beginning_of_month
        end_date = start_date.at_end_of_month if end_date.nil?

        # Get all teams
        team_ids = Metrics::TeamAnalysis.tenant_team_ids(2)

        teams = Team.find(team_ids)

        data = {}
        teams.each do |t|

          check_ins = self.get_events_with_checkins_for_team(t.id, start_date, end_date).size
          new_players = self.get_new_players_for_team(t.id, start_date, end_date).size
          retention = self.calcuate_retention(t.id, start_date, end_date)

          total_points = 0

          total_points += check_ins * 2
          total_points += new_players * 3

          if retention <= 24
            # Do nothing
          elsif retention <= 49
            total_points += 2
          elsif retention <= 74
            total_points += 5
          elsif retention <= 99
            total_points += 10
          elsif retention == 100
            total_points += 20
          end

          region = "No Region"

          if !t.club.nil? && !t.club.location.nil? && !t.club.location.lat.nil?
            lat = t.club.location.lat

            if lat >= 52.764873
              region = "North"
            elsif lat >= 51.757639
              region = "Midlands"
            else
              region = "South"
            end
          end


          team_row = {
            team_id: t.id,
            team: t.name,
            region: region,
            check_ins: check_ins,
            new_players: new_players,
            retention: retention.round(1),
            points: total_points
          }
          data[t.id] = team_row
        end

        return data
      end


      def get_player_attendance_for_month(team_id, start_date=Date.new)
        start_date_str = start_date.strftime("%Y-%m-%d")

        end_date = start_date.at_end_of_month
        end_date_str = end_date.strftime("%Y-%m-%d")

        # Existing Players
        data = {}

        existing_players_ids = Metrics::Tools.execute_query(Metrics::Query::get_existing_players_for_team(team_id, start_date_str, end_date_str))
        new_players_ids = self.get_new_players_for_team(team_id, start_date, end_date)
        players_ids = existing_players_ids + new_players_ids

        players = User.find(players_ids)
        players.each do |u|
          data[u.id] = {
            name: u.name,
            gender: u.profile.gender,
            experience: (u.tenanted_attrs.nil? || u.tenanted_attrs[:player_history].nil?) ? "" : u.tenanted_attrs[:player_history]
          }
        end

        event_dates = []

        event_ids = Metrics::Tools.execute_query(Metrics::Query::get_events_for_team(team_id, start_date_str, end_date_str))
        events = Event.find(event_ids)
        events.each do |e|
          date_str = e.time.strftime("%Y-%m-%d")

          tses = e.teamsheet_entries
          tses.each do |t|
            u = data[t.user_id]
            next if u.nil?
            if u[date_str].nil? || u[date_str] == false
              u[date_str] = t.checked_in
            end
          end

          event_dates << date_str
        end

        puts data.to_yaml

        
        return {
          dates: event_dates,
          data: data
        }
      end

    end
  end
end