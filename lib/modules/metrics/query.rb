module Metrics
  class Query
    class << self
      def teams_with_more_than(number_of_players=4)
        return "SELECT team_id FROM teams, team_roles
          WHERE teams.id = team_roles.team_id
          AND role_id=1
          AND team_roles.user_id NOT IN (7104,7105,7106,7107,7108,7109,7110)
          AND teams.demo_mode = 0
          GROUP BY team_id
          HAVING COUNT(team_id) > #{number_of_players}"
      end

      def number_members(type=:after, team_id, day)

        comparision_op = type==:after ? ">=" : "<="

        date_str = "created_at #{comparision_op} \"#{day}\""

        return "SELECT DISTINCT user_id, created_at FROM team_roles
          WHERE team_roles.team_id = #{team_id}
          AND #{date_str}
          GROUP BY user_id"
      end

      def teams_with_more_than_from_ids_query(in_team_ids, number_of_players=4)
        return "SELECT team_id FROM teams, team_roles
          WHERE teams.id = team_roles.team_id
          AND teams.id IN (#{in_team_ids.join(',')})
          AND role_id=1
          AND team_roles.user_id NOT IN (7104,7105,7106,7107,7108,7109,7110)
          AND teams.demo_mode = 0
          GROUP BY team_id
          HAVING COUNT(team_id) > #{number_of_players}"
      end

      def active_teams_query(day, include_team_ids)
        
        include_teams_str = include_team_ids.join(",")

        return "SELECT team_id, COUNT(team_id) AS 'events'
          FROM events, teams
          WHERE teams.id=team_id AND team_id
          IN (#{include_teams_str})
          AND teams.created_at <= \"#{day}\"
          AND date_sub(\"#{day}\", INTERVAL 7 DAY) <= events.time
          AND date_add(\"#{day}\", INTERVAL 7 DAY) >= events.time
          GROUP BY team_id"
      end

      # Strictly Active users
      # Users who have posted a message/comment, responded to an availability or created/updated an event
      def users_who_created_activity_query(start_day, end_day, user_ids_in=nil)

        return "SELECT * FROM users WHERE 0" if !user_ids_in.nil? && user_ids_in.size == 0

        and_user_ids_in = "AND subj_id IN (#{user_ids_in.join(",")})" unless user_ids_in.nil?

        return "SELECT subj_id
          FROM activity_items
          WHERE created_at BETWEEN '#{start_day} 00:00:00' AND '#{end_day} 23:59:59'
          AND subj_type = \"User\"
          AND obj_type IN (\"Event\", \"EventMessage\", \"InviteResponse\")
          #{and_user_ids_in}
          GROUP BY subj_id"
      end

      def users_who_commented_query(start_day, end_day, user_ids_in=nil)

        return "SELECT * FROM users WHERE 0" if !user_ids_in.nil? && user_ids_in.size == 0

        and_user_ids_in = "AND user_id IN (#{user_ids_in.join(",")})" unless user_ids_in.nil?

        return "SELECT DISTINCT user_id
          FROM activity_item_comments
          WHERE created_at BETWEEN '#{start_day} 00:00:00' AND '#{end_day} 23:59:59'
          #{and_user_ids_in}"
      end

      def users_who_liked_query(start_day, end_day, user_ids_in=nil)

        return "SELECT * FROM users WHERE 0" if !user_ids_in.nil? && user_ids_in.size == 0

        and_user_ids_in = "AND user_id IN (#{user_ids_in.join(",")})" unless user_ids_in.nil?

        return "SELECT DISTINCT user_id
          FROM activity_item_likes
          WHERE created_at BETWEEN '#{start_day} 00:00:00' AND '#{end_day} 23:59:59'
          #{and_user_ids_in}"
      end

      # Users who received notifications
      # Users who are receiving notifications (sms/push)
      def consuming_users(day, user_ids_in=nil)

        and_user_ids_in = "AND user_id IN (#{user_ids_in.join(",")})" unless user_ids_in.nil?

        return "SELECT DISTINCT user_id
          FROM ns2_notification_items
          WHERE created_at BETWEEN '#{day} 00:00:00' AND '#{day} 23:59:59'
          #{and_user_ids_in}"
      end

      # Users who received notifications
      # Users who are receiving notifications (sms/push)
      def users_received_notification_query(start_day, end_day, user_ids_in=nil)

        and_user_ids_in = "AND user_id IN (#{user_ids_in.join(",")})" unless user_ids_in.nil?

        return "SELECT DISTINCT user_id
          FROM ns2_notification_items
          WHERE type IN (\"SmsNotificationItem\",\"PushNotificationItem\")
          AND created_at BETWEEN '#{start_day} 00:00:00' AND '#{end_day} 23:59:59'
          #{and_user_ids_in}"
      end

      def users_received_email_notification_query(start_day, end_day, user_ids_in=nil)

        and_user_ids_in = "AND ni.user_id IN (#{user_ids_in.join(",")})" unless user_ids_in.nil?

        return "SELECT ni.user_id
          FROM ns2_notification_items ni, sendgrid_email_events se
          WHERE ni.id=se.email_notification_id
          AND se.event IN (\"click\",\"open\")
          AND se.created_at BETWEEN '#{start_day} 00:00:00' AND '#{end_day} 23:59:59'
          #{and_user_ids_in}
          GROUP BY user_id"
      end

      # Users invited
      # Users who were invited to BF in period by users
      def users_invited_by_query(start_day, end_day, user_ids_in=nil)

        return "SELECT * FROM users WHERE 0" if !user_ids_in.nil? && user_ids_in.size == 0

        and_user_ids_in = "AND u.invited_by_source_user_id IN (#{user_ids_in.join(",")})" unless user_ids_in.nil?

        return "SELECT COUNT(*)
                FROM users u
                WHERE u.created_at BETWEEN '#{start_day} 00:00:00' AND '#{end_day} 23:59:59'
                AND u.invited_by_source_user_id IS NOT NULL
                #{and_user_ids_in}"
      end 

      # Users invited
      # Users who were invited to BF in period by users
      def users_invited_by_query_v2(start_day, end_day, user_ids_in=nil)

        return "SELECT * FROM users WHERE 0" if !user_ids_in.nil? && user_ids_in.size == 0

        and_user_ids_in = "AND u.invited_by_source_user_id IN (#{user_ids_in.join(",")})" unless user_ids_in.nil?

        return "SELECT u.id
                FROM users u
                WHERE u.created_at BETWEEN '#{start_day} 00:00:00' AND '#{end_day} 23:59:59'
                AND u.invited_by_source_user_id IS NOT NULL
                #{and_user_ids_in}"
      end

     # SIGN UPS
      def users_signups_query(start_day, end_day=nil, user_ids_in=nil)

        end_day = start_day if end_day.nil?
        and_user_ids_in = "AND u.id IN (#{user_ids_in.to_a.join(",")})" unless user_ids_in.nil?

        return "SELECT DISTINCT u.id
                FROM users u
                WHERE u.created_at BETWEEN '#{start_day} 00:00:00' AND '#{end_day} 23:59:59'
                #{and_user_ids_in}"
      end

      def users_signups_not_invited_query(start_day, end_day=nil, user_ids_in=nil)

        end_day = start_day if end_day.nil?
        and_user_ids_in = "AND u.id IN (#{user_ids_in.join(",")})" unless user_ids_in.nil?

        return "SELECT DISTINCT u.id
                FROM users u
                WHERE u.created_at BETWEEN '#{start_day} 00:00:00' AND '#{end_day} 23:59:59'
                AND u.invited_by_source_user_id IS NULL
                #{and_user_ids_in}"
      end

      def users_unsubscribed_query(start_day, end_day=nil, user_ids_in=nil)

        end_day = start_day if end_day.nil?
        and_user_ids_in = "AND u.user_id IN (#{user_ids_in.join(",")})" unless user_ids_in.nil?

        return "SELECT DISTINCT u.user_id
                FROM users_unsubscribed u
                WHERE u.created_at BETWEEN '#{start_day} 00:00:00' AND '#{end_day} 23:59:59'
                #{and_user_ids_in}"
      end

      # FOLLOWS
      def users_follows_query(day, user_ids_in=nil, invited_by_source=nil)

        and_user_ids_in = "AND tr.user_id IN (#{user_ids_in.join(",")})" unless user_ids_in.nil?
        and_invited_by_source = "AND u.invited_by_source IN (#{invited_by_source.join(",")})" unless invited_by_source.nil?

        return "SELECT DISTINCT tr.user_id
                FROM team_roles tr, users u
                WHERE tr.created_at BETWEEN '#{day} 00:00:00' AND '#{day} 23:59:59'
                AND tr.role_id = 4
                AND u.id = tr.user_id
                #{and_invited_by_source}
                #{and_user_ids_in}"
      end

      def users_follows_by_medium_query(medium, day, user_ids_in=nil, invited_by_source=nil)

        and_user_ids_in = "AND tr.user_id IN (#{user_ids_in.join(",")})" unless user_ids_in.nil?
        and_invited_by_source = "AND u.invited_by_source IN (#{invited_by_source.join(",")})" unless invited_by_source.nil?

        medium_query = (medium == "undefined") ? "AND utm.medium IS NULL" : "AND utm.medium = \"#{medium}\""

        return "SELECT DISTINCT tr.user_id
                FROM team_roles tr, users u, utm_data utm
                WHERE tr.created_at BETWEEN '#{day} 00:00:00' AND '#{day} 23:59:59'
                AND tr.role_id = 4
                AND u.id = tr.user_id
                #{and_invited_by_source}
                AND utm.user_id = u.id
                #{medium_query}
                #{and_user_ids_in}"
      end

      def users_downloaded_query(user_ids_in)

        return "SELECT * FROM users WHERE 0" if user_ids_in.nil? || user_ids_in.size == 0

        return "SELECT DISTINCT user_id
          FROM mobile_devices
          WHERE user_id IN (#{user_ids_in.join(",")})"
      end

      def users_downloaded_by_medium_query(medium, user_ids_in)

        return "SELECT * FROM users WHERE 0" if user_ids_in.nil? || user_ids_in.size == 0

        medium_query = (medium == "undefined") ? "AND utm.medium IS NULL" : "AND utm.medium = \"#{medium}\""

        return "SELECT DISTINCT md.user_id
          FROM mobile_devices md, utm_data utm
          WHERE md.user_id IN (#{user_ids_in.join(",")})
          AND utm.user_id = md.user_id
          #{medium_query}"
      end

      def users_invited_query(user_ids_in)

        return "SELECT * FROM users WHERE 0" if user_ids_in.nil? || user_ids_in.size == 0

        return "SELECT invited_by_source_user_id, COUNT(*) AS invites
                FROM users
                WHERE invited_by_source_user_id IN (#{user_ids_in.join(",")})
                GROUP BY invited_by_source_user_id
                HAVING COUNT(*) > 5"
      end

      def users_invited_by_medium_query(medium, user_ids_in)

        return "SELECT * FROM users WHERE 0" if user_ids_in.nil? || user_ids_in.size == 0

        medium_query = (medium == "undefined") ? "AND utm.medium IS NULL" : "AND utm.medium = \"#{medium}\""

        return "SELECT u.invited_by_source_user_id, COUNT(*) AS invites
                FROM users u, utm_data AS utm
                WHERE u.invited_by_source_user_id IN (#{user_ids_in.join(",")})
                AND utm.user_id = u.id
                #{medium_query}
                GROUP BY u.invited_by_source_user_id
                HAVING COUNT(*) > 5"
      end

      def accepting_users_query(start_date, end_date, in_user_ids=nil)
        return "SELECT u.id FROM users u, roles_users ur
        WHERE u.invited_by_source_user_id IS NOT NULL
        AND u.created_at >= \"#{start_date}\" AND u.created_at <= \"#{end_date}\"
        AND ur.user_id = u.id AND ur.role_id=6"
      end

      def users_followed_faft_team_ids(day, user_ids_in=nil)

        return "SELECT * FROM users WHERE 0" if !user_ids_in.nil? && user_ids_in.size == 0

        and_user_ids_in = "AND subj_id IN (#{user_ids_in.join(",")})" unless user_ids_in.nil?

        return "SELECT users.id FROM users WHERE invited_by_source IN (\"FAFTTEAMFOLLOW\")"
      end

      def teams_in_divisions_query(divisions)
        return "SELECT teams.id
        FROM teams, divisions_teams, divisions
        WHERE divisions_teams.`team_id` = teams.id
        AND divisions.id=divisions_teams.division_id
        AND divisions.id IN (#{divisions.join(',')})"
      end

      def new_teams_query(day, in_team_ids=nil)

        if !in_team_ids.nil?
          include_teams_str = "AND teams.id IN (" + in_team_ids.join(",") + ")"
        end

        return "SELECT teams.id
        FROM teams
        WHERE created_at BETWEEN '#{day} 00:00:00' AND '#{day} 23:59:59'
        #{include_teams_str}
        AND created_by_id IS NOT NULL"
      end

      def games_in_day(day, in_team_ids=nil)

        if !in_team_ids.nil?
          include_teams_str = "AND team_id IN (" + in_team_ids.join(",") + ")"
        end

        return "SELECT events.id
          FROM events
          WHERE time BETWEEN '#{day} 00:00:00' AND '#{day} 23:59:59'
          #{include_teams_str}"
      end

      def notification_by_medium_query(medium, start_date_str, end_date_str, user_ids=nil)

        if !medium.nil? && medium!="all"
          medium_str = "AND medium IN (" + medium.join(",") + ")"
        end

        return "SELECT type, datum FROM ns2_notification_items
          WHERE processed_at BETWEEN '#{start_date_str} 00:00:00' AND '#{end_date_str} 23:59:59'
          #{medium_str}"
      end

      # Return all adult teams
      def adult_teams_query()
        return "SELECT teams.id
        FROM (teams, team_profiles)
        LEFT JOIN (divisions_teams)
        ON (divisions_teams.team_id = teams.id)
        WHERE team_profiles.id=teams.profile_id
        AND team_profiles.age_group > 21
        AND divisions_teams.division_id IS NULL"
      end

      # Return all junior teams
      def junior_teams_query()
        return "SELECT teams.id
        FROM (teams, team_profiles)
        LEFT JOIN (divisions_teams)
        ON (divisions_teams.team_id = teams.id)
        WHERE team_profiles.id=teams.profile_id
        AND team_profiles.age_group <= 21
        AND divisions_teams.division_id IS NULL"
      end

      # Return all league teams (non-faft)
      def league_teams_query()
        return "SELECT dt.team_id
        FROM divisions_teams dt, leagues l, divisions d
        WHERE l.id = d.league_id
        AND d.id = dt.division_id
        AND l.source_id IS NULL"
      end

       # Return all league teams (non-faft)
      def faft_teams_query()
        return "SELECT dt.team_id
        FROM divisions_teams dt, leagues l, divisions d
        WHERE l.id = d.league_id
        AND d.id = dt.division_id
        AND l.source_id IS NOT NULL
        AND l.source = \"faft\""
      end

      # Return all teams for tenant
      def tenant_teams_query(tenant_id)
        return "SELECT t.id
        FROM teams t
        WHERE t.tenant_id = #{tenant_id}"
      end

      ###
      # USER SEGMENTS
      ###

      def users_by_team_role(roles, before_date=Date.today)
        roles_str = roles.join(",")
        date_str = before_date.strftime("%Y-%m-%d")
        return "SELECT DISTINCT u.id FROM users u, team_roles tr WHERE u.id=tr.user_id AND role_id IN (#{roles_str}) AND u.created_at <= \"#{date_str}\""
      end

      def users_in_divisions_query(divisions)
        return "SELECT DISTINCT users.id
        FROM users, team_roles, teams, divisions_teams, divisions
        WHERE users.id
        IN
          (SELECT DISTINCT team_roles.user_id
            FROM team_roles
            LEFT JOIN divisions_teams ON divisions_teams.`team_id`=team_roles.team_id
            WHERE divisions_teams.team_id IS NOT NULL)
        AND users.id=team_roles.user_id
        AND teams.id = team_roles.team_id
        AND divisions_teams.`team_id` = teams.id
        AND divisions.id=divisions_teams.division_id
        AND divisions.id IN (#{divisions.join(',')})"
      end

      ###
      # REWARDS AND RECOGNITION
      ###

      def get_checkins_for_team(team_id, start_date_str, end_date_str, in_user_ids)
        if !in_user_ids.nil?
          include_users_str = "AND ts.user_id IN (" + in_user_ids.join(",") + ")"
        end

        return "SELECT * FROM events e, teamsheet_entries ts
        WHERE e.team_id = \"#{team_id}\"
        AND e.time >= \"#{start_date_str}\"
        AND e.time <= \"#{end_date_str}\"
        AND e.id=ts.event_id
        AND checked_in = 1
        #{include_users_str}"
      end

      def get_events_with_checkins_for_team(team_id, start_date_str, end_date_str, in_user_ids)
        if !in_user_ids.nil?
          include_users_str = "AND ts.user_id IN (" + in_user_ids.join(",") + ")"
        end

        return "SELECT DISTINCT e.id FROM events e, teamsheet_entries ts
        WHERE e.team_id = \"#{team_id}\"
        AND e.time >= \"#{start_date_str}\"
        AND e.time <= \"#{end_date_str}\"
        AND e.id=ts.event_id
        AND checked_in = 1
        #{include_users_str}"
      end

      def get_events_for_team(team_id, start_date_str, end_date_str)
        return "SELECT e.id FROM events e
        WHERE e.team_id = \"#{team_id}\"
        AND e.time >= \"#{start_date_str}\"
        AND e.time <= \"#{end_date_str}\""
      end

      def get_existing_players_for_team(team_id, start_date_str, end_date_str)
        return "SELECT r.user_id FROM poly_roles r
        WHERE r.obj_id = \"#{team_id}\"
        AND r.obj_type = \"Team\"
        AND r.created_at <= \"#{end_date_str}\"
        AND (r.trashed_at IS NULL OR r.trashed_at >= \"#{start_date_str}\")"
      end

      def get_new_players_for_team(team_id, start_date_str, end_date_str)
        return "SELECT r.user_id FROM poly_roles r
        WHERE r.obj_id = \"#{team_id}\"
        AND r.obj_type = \"Team\"
        AND r.created_at >= \"#{start_date_str}\"
        AND r.created_at <= \"#{end_date_str}\""
      end
    end
  end
end