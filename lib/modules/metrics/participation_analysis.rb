module Metrics
  class ParticipationAnalysis
    class << self

      # Get all users who participated in period
      def all(tenant_id=nil, unit=:month, start_date=nil)
        
        start_date = Date.today if start_date.nil?

        if unit == :alltime
          end_date = Date.today
        elsif unit == :month
          end_date = start_date.at_end_of_month
        elsif unit == :week
          end_date = start_date.at_end_of_week
        end

        @participated = MitooMetrics::Users::Participated.new
        @participated.tenant_id = tenant_id
        
        @participated.in_period(start_date, end_date)
      end

      # Get summary stats for period
      def summary(tenant_id=nil, unit=:month, start_date=nil)

        all_users = self.all(tenant_id, unit, start_date)

        by_experience = self.by_experience

        by_frequency = self.by_frequency(tenant_id, unit, start_date)

        total_infrequent = 0
        total_frequent = 0

        if !by_frequency[0].nil?
          total_frequent = by_frequency[0][:thrice]
          total_infrequent = by_frequency[0][:once] + by_frequency[0][:twice]
        end

        return {
          total_players: all_users.size,
          new_to_rugby: by_experience[:new_to_rugby],
          total_frequent: total_frequent,
          total_infrequent: total_infrequent
        }
      end

      # Get a breakdown of all users by gender
      def by_gender(tenant_id=nil, unit=:month, start_date=nil, end_date=nil)
        all_users = self.all(tenant_id, unit, start_date)
        users = self.get_users_from_ids(all_users)

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
      end

      # Segment all users by gender
      def by_experience(tenant_id=nil, unit=:month, start_date=nil)
        all_users = self.all(tenant_id, unit, start_date)
        users = self.get_users_from_ids(all_users.to_a)

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

      # Segment all users by source
      def by_source(tenant_id=nil, unit=:month, start_date=nil)
        all_users = self.all(tenant_id, unit, start_date)
        users = self.get_users_from_ids(all_users)

        web = Set.new
        operator = Set.new
        imported = Set.new
        unset = Set.new

        users.each do |u|
          if u.invited_by_source=="EVENT"
            web.add(u)
          elsif u.invited_by_source=="TEAMPROFILE"
            operator.add(u)
          elsif u.invited_by_source=="O2_TOUCH_IMPORT"
            imported.add(u)
          else
            unset.add(u)
          end
        end
          
        return {
          web: web.size,
          operator: operator.size,
          imported: imported.size,
          unset: unset.size
        }
      end

      # Segment all users by participation frequency
      def by_frequency(tenant_id=nil, interval=:month, start_date=nil, to_date=nil)

        tenant_id = 1 if tenant_id.nil?
        to_date = start_date.at_end_of_month if to_date.nil?

        start_date_str = start_date.strftime("%Y-%m-%d")
        end_date_str = to_date.strftime("%Y-%m-%d")
        clear_cache = true if to_date >= Date.today

        results = MitooMetrics::Tools.execute_cached_query(MitooMetrics::Query.users_participation_count_in_tenanted_team(tenant_id, start_date_str, end_date_str), clear_cache)
        
        data = {}

        results.each do |r|
          count = r[1]
          data[count] = 0 if data[count].nil?
          data[count] += 1
        end

        once = data[1].nil? ? 0 : data[1]
        twice = data[2].nil? ? 0 : data[2]

        thrice_plus = 0
        (3..data.length).each do |i|
          thrice_plus += data[i].nil? ? 0 : data[i]
        end

        return [
          { date: start_date_str, once: once, twice: twice, thrice: thrice_plus }
        ]
      end

      def get_users_from_ids(user_ids)
        User.find(user_ids.to_a)#.includes(:user_profile)
      end

    end
  end
end