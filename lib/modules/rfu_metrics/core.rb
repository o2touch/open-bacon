module RfuMetrics
  class Core
    class << self

      def overview_summary(until_date)

        tenant_id = 2
        
        total_players = self.total_players(until_date)
        total_users = self.total_users(until_date)

        # Total events
        events = MitooMetrics::Events.created
        events.tenant_id = tenant_id
        event_count = events.in_period(Date.new(2014,4,1), until_date).size

        # Clubs Total Count
        active_teams = MitooMetrics::Teams.active
        active_teams.tenant_id = tenant_id
        total_teams = active_teams.in_period(Date.new(2014,4,1), until_date)

        data = {
          total_users: total_players.size,
          total_users_admins: total_users.size,
          club_activations: total_teams.size,
          total_events: event_count,
          user_engagement: 30
        }

        return data
      end

      def totals_set(until_date)
        tenant_id = 2

        teams = MitooMetrics::Teams.created
        teams.tenant_id = tenant_id
        total_teams = teams.in_period(Date.new(2014,4,1), until_date)

        total_users = MitooMetrics::Users.in_teams(total_teams, until_date)

        [total_teams, total_users]
      end

      def total_users(until_date)

        total_teams, total_users = self.totals_set(until_date)

        users = User.find(total_users.to_a)
        
        return users
      end

      def total_players(until_date)

        total_teams, total_users = self.totals_set(until_date)

        admins = []

        teams = Team.find(total_teams.to_a)
        teams.each do |t|
          admins << t.organiser_ids
        end

        total_players = total_users - admins.uniq!

        players = User.find(total_players.to_a)
        
        return players
      end

      def total_users_activated(until_date)

        players = self.total_players(until_date)
        registered_players = players.select(&:is_registered?)

        return registered_players
      end

      def total_users_by_gender(start_date)
    
        start_date = Date.new(2014,4,1)
        until_date = Date.today
        tenant_id = 2
        
        # Total Users from teams
        teams = MitooMetrics::Teams.created
        teams.tenant_id = tenant_id
        total_teams = teams.in_period(start_date, until_date)

        total_users = MitooMetrics::Users.in_teams(total_teams, until_date)
        users = User.find(total_users.to_a)

        male = Set.new
        female = Set.new
        unset = Set.new

        users.each do |u|
          if u.profile.gender=="m"
            male.add(u)
          elsif u.profile.gender=="f"
            female.add(u)
          else
            unset.add(u)
          end
        end
          
        return {
          male: male.size,
          female: female.size,
          unset: unset.size
        }

        return data
      end

      def total_users_by_experience(until_date=nil)

        start_date = Date.new(2014,4,1)
        until_date = Date.today if until_date.nil?
        tenant_id = 2
        
        # Total Users from teams
        teams = MitooMetrics::Teams.created
        teams.tenant_id = tenant_id
        total_teams = teams.in_period(start_date, until_date)

        total_users = MitooMetrics::Users.in_teams(total_teams, until_date)
        users = User.find(total_users.to_a)

        new_to_rugby = Set.new
        existing = Set.new
        unset = Set.new

        users.each do |u|

          if u.tenanted_attrs.nil? || u.tenanted_attrs[:player_history].nil?
            unset.add(u)
            next;
          end

          if u.tenanted_attrs[:player_history]=="new"
            new_to_rugby.add(u)
          elsif u.tenanted_attrs[:player_history]=="existing"
            existing.add(u)
          else
            unset.add(u)
          end
        end
          
        return {
          new_to_rugby: new_to_rugby.size,
          existing: existing.size,
          unset: unset.size
        }
      end

    end
  end
end