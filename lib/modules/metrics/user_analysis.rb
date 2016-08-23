# won't work because I removed the metrics service, innit
# module Metrics
# 	class UserAnalysis
# 		class << self

#       def cache_key_prefix
#         "metrics:user_analysis:"
#       end

#       # Weekly users between
#       def weekly_user_data_between(week_begin, week_end, user_ids=nil, clear_cache=false)
        
#         results = []

#         ever_active = Set.new

#         for i in week_begin..week_end
#           key = i.strftime("%Y-%m-%d")
          
#           new_row = {}
#           new_row[:week] = key

          
#           # actives = self.active_users_in_week(:strictly_active, i, year, user_ids, clear_cache)
#           # active_last_week = self.active_users_in_week(:strictly_active, i-1, year, user_ids, clear_cache)
#           # consumers = self.consuming_users(i, year, user_ids, clear_cache)
        
#           signups = self.user_signups_not_invited_in_week(i, user_ids, clear_cache)
#           actives = self.active_users_in_week(:strictly_active, i, user_ids, clear_cache)  

#           active_not_new = Set.new(actives) - Set.new(signups)
#           # ever_active = ever_active|active_not_new

#           # deactives = Set.new(active_last_week) - Set.new(actives)
#           # total_deactives = ever_active - actives

#           new_row[:signups] = signups.size
#           new_row[:actives] = active_not_new.size
#           # new_row[:deactives] = deactives.size
#           # new_row[:consumers] = (consumers - signups).size
#           # new_row[:churn] = 0
#           # new_row[:net] = new_row[:signups] + new_row[:actives] - new_row[:deactives] - new_row[:churn]

#           results << new_row
#         end

#         return results
#       end

#       # Daily Active users between
#       def daily_active_users_between(metric, date_begin, date_end, user_ids=nil, clear_cache=false)
        
#         results = {}

#         for day in date_begin..date_end
#           key = day.strftime("%Y-%m-%d")
#           results[key] = {}

#           if metric == :strictly_active || metric == :loosely_active
#             results[key][:actives] = self.active_users_in_day(metric, day, user_ids, clear_cache)
#           elsif metric == :consumers
#             results[key][:actives] = self.consuming_users(day, user_ids, clear_cache)
#           end

#           results[key][:invited] = self.users_invited_in_day(day, user_ids, clear_cache)
#           results[key][:accepting_users] = self.accepting_users_in_day(day, user_ids, clear_cache)
#         end

#         return results
#       end
      
#       # Weekly Active users between
#       def weekly_active_users_between(metric, week_begin, week_end, user_ids=nil, clear_cache=false)
        
#         results = {}

#         for i in week_begin..week_end
#           key = self.get_week_key(i)
#           results[key] = {}

#           if metric == :strictly_active || metric == :loosely_active
#             results[key][:actives] = self.active_users_in_week(metric, i, user_ids, clear_cache)
#           elsif metric == :consumers
#             results[key][:actives] = self.consuming_users(i, user_ids, clear_cache)
#           end

#           results[key][:invited] = self.users_invited_in_week(i, user_ids, clear_cache)
#           results[key][:accepting_users] = self.accepting_users_in_week(i, user_ids, clear_cache)
#         end

#         return results
#       end

#       # Monthly Active users between
#       def monthly_active_users_between(m_begin, m_end, user_ids=nil, clear_cache=false)
        
#         results = {}

#         for i in m_begin..m_end
#           next if i != i.at_beginning_of_month
#           key = self.get_week_key(i)
#           results[key] = {}
#           results[key][:actives] = self.active_users_in_month(:strictly_active, i, user_ids, clear_cache)
#           results[key][:invited] = self.users_invited_in_month(:strictly_active, i, user_ids, clear_cache)
#           results[key][:accepting_users] = self.accepting_users_in_month(:strictly_active, i, user_ids, clear_cache)
#         end

#         return results
#       end

#       def last_30_day_engagement(day)

#         start_date = day - 30.days
#         end_date = day

#         results = []

#         (start_date..end_date).each do |date|

#           players = Metrics::Tools.execute_cached_query(Metrics::Query.users_by_team_role([1,3], date)).flatten
#           followers = Metrics::Tools.execute_cached_query(Metrics::Query.users_by_team_role([4], date)).flatten
#           organisers = Metrics::Tools.execute_cached_query(Metrics::Query.users_by_team_role([2], date)).flatten

#           result = {}
#           result[:day] = date.strftime("%Y-%m-%d")
#           result[:dau] = self.day_engagement(date, players)
#           result[:dau_followers] = self.day_engagement(date, followers)
#           result[:dau_organisers] = self.day_engagement(date, organisers)
#           results << result
#         end

#         return results
#       end

#       # Monthly Engagement
#       def monthly_engagement(month, user_ids=nil, clear_cache=false)

#         today = Date.today
#         m_begin, m_end = self.get_month_begin_and_end_from_date(month)

#         # average DAU
#         daus = []
#         (m_begin..m_end).each do |day|
#           next if day > today
#           actives = self.active_users_in_day(:strictly_active, day, user_ids, clear_cache)
#           actives_over_month = self.active_users_in_last_30_days(:strictly_active, day, user_ids, clear_cache)
#           daus << (actives.size.to_f / actives_over_month.size.to_f) * 100.0
#         end

#         average_dau = 0
#         daus.each { |dau| average_dau += dau }

#         return average_dau / daus.size
#       end

#       def day_engagement(day, user_ids=nil, clear_cache=false)
#         clear_cache = true
#         date_str = day.strftime("%Y-%m-%d")
#         cache_key = cache_key_prefix + "day_engagement:#{date_str}"
#         cache_miss = true # Only want to cache if user_ids is not nil

#         unless user_ids.nil?
#           user_ids_hash = Digest::MD5.hexdigest(user_ids.join(","))
#           cache_key += ":#{user_ids_hash}"
#           cache_miss = false
#         end

#         engagement = Rails.cache.fetch(cache_key, :force => cache_miss) do
#           actives = self.active_users_in_day(:strictly_active, day, user_ids, clear_cache)
#           actives_over_month = self.active_users_in_last_30_days(:strictly_active, day, user_ids, clear_cache)
#           (actives.size == 0) ? 0 : (actives.size / actives_over_month.size.to_f) * 100.0
#         end

#         return engagement
#       end

#       # Weekly Active users between
#       def weekly_user_growth_between(week_begin, week_end, user_ids=nil, clear_cache=false)
        
#         results = {}
#         order = []

#         users_ever_active = Set.new

#         for i in week_begin..week_end
#           next if i != i.at_beginning_of_week || i >= Date.today
#           key = self.get_week_key(i)
#           results[key] = {}
#           results[key][:day]  = i
#           results[key][:data] = self.user_growth_in_week(i, user_ids, users_ever_active, clear_cache)

#           users_ever_active = results[key][:data][:active][:total]

#           order << key
#         end

#         results[:keys] = order

#         return results
#       end

#       # Weekly Active users between
#       def user_growth_30_day(date_begin, date_end, user_ids=nil, clear_cache=false)
        
#         results = {}
#         order = []

#         users_ever_active = Set.new

#         for i in date_begin..date_end
#           next if i >= Date.today
#           key = i.strftime("%Y-%m-%d")

#           results[key] = {}
#           results[key][:day]  = i
#           results[key][:data] = self.user_growth_in_last_30_days(i, user_ids, users_ever_active, clear_cache)

#           users_ever_active = results[key][:data][:active][:total]

#           order << key
#         end

#         results[:keys] = order

#         return results
#       end

#       # Cohort: Signed-up then active in period
#       def cohorted_users_between(week_begin, week_end, until_weeks_after=12, user_ids=nil, clear_cache=false)

#         results = {}

#         # Signups in week
#         (week_begin..week_end).each do |i|
          
#           next if i != i.at_beginning_of_week || i >= Date.today

#           weeks = (week_end - i) / 7
#           key = self.get_week_key(i)

#           results[key] = {}
#           results[key][:people] = self.user_signups_in_week(i, user_ids, clear_cache)
#           results[key][:periods_later] = {}

#           weeks = (weeks < until_weeks_after) ? weeks : until_weeks_after
#           (1..weeks).each do |weeks_later|
#             j = i.advance(:days => (weeks_later * 7))
#             results[key][:periods_later][weeks_later] = self.active_users_in_week(:strictly_active, j, results[key][:people], clear_cache)
#           end

#         end        

#         return results
#       end

#       def monthly_cohorted_users_between(m_begin, m_end, user_ids=nil, clear_cache=false)

#         results = {}

#         # Signups in week
#         for i in m_begin..m_end
          
#           next if i != i.at_beginning_of_month

#           periods = m_end.month - i.month + 12 * (m_end.year - i.year)
#           key = i.strftime("%Y-%m")

#           results[key] = {}
#           results[key][:people] = self.user_signups_in_month(i, user_ids, clear_cache)
#           results[key][:periods_later] = {}

#           (1..periods).each do |periods_later|
#             j = i.advance(:months => periods_later)
#             results[key][:periods_later][periods_later] = self.active_users_in_month(:strictly_active, j, results[key][:people], clear_cache)
#           end

#         end

#         return results
#       end

#       def daily_cohorted_users_between(day_begin, day_end, year=2013, user_ids=nil, clear_cache=false)

#         results = {}

#         # Signups in week
#         for i in day_begin..day_end
          
#           periods = day_end - i
#           key = i.strftime("%Y-%m-%d")

#           results[key] = {}
#           results[key][:people] = self.user_signups_in_day(i, user_ids, clear_cache)
#           results[key][:periods_later] = {}

#           (1..periods).each do |periods_later|
#             j = i + periods_later
#             results[key][:periods_later][periods_later] = self.active_users_in_day(:strictly_active, j, results[key][:people], clear_cache)
#           end

#         end

#         return results
#       end

#       def monthly_cohorted_invited_users_between(m_begin, m_end, user_ids=nil, clear_cache=false)

#         results = {}

#         # Signups in week
#         for i in m_begin..m_end
          
#           next if i != i.at_beginning_of_month

#           periods = m_end.month - i.month + 12 * (m_end.year - i.year)
#           key = i.strftime("%Y-%m")

#           results[key] = {}
#           results[key][:people] = self.user_signups_not_invited_in_month(i, user_ids, clear_cache)
#           results[key][:periods_later] = {}

#           (1..periods).each do |periods_later|
#             j = i.advance(:months => periods_later)
#             results[key][:periods_later][periods_later] = self.users_invited_in_month(j, results[key][:people], clear_cache)
#           end

#         end

#         return results
#       end

#       ###
#       # USER SIGNUPS
#       ###
#       def user_signups_in_day(day, user_ids=nil, clear_cache=false)
#         return self.user_signups_in_period(day, day, user_ids, clear_cache)
#       end

#       def user_signups_in_week(week, user_ids=nil, clear_cache=false)
#         wk_begin, wk_end = self.get_week_begin_and_end_from_date(week)
#         return self.user_signups_in_period(wk_begin, wk_end, user_ids, clear_cache)
#       end

#       def user_signups_in_month(month, user_ids=nil, clear_cache=false)
#         m_begin, m_end = self.get_month_begin_and_end_from_date(month)
#         return self.user_signups_in_period(m_begin, m_end, user_ids, clear_cache)
#       end

#       def user_signups_in_period(start_date, end_date, user_ids=nil, clear_cache=false)

#         data = []

#         start_date_str = start_date.strftime("%Y-%m-%d")
#         end_date_str = end_date.strftime("%Y-%m-%d")

#         clear_cache = true if end_date >= Date.today

#         results = Metrics::Tools.execute_cached_query(Metrics::Query.users_signups_query(start_date_str, end_date_str, user_ids), clear_cache)
#         results.each do |row|
#           data << row[0] if !data.include?(row[0])
#         end

#         return data
#       end

#       ###
#       # USER SIGNUPS NOT INVITED
#       ###
#       def user_signups_not_invited_in_week(wk_start_date, user_ids=nil, clear_cache=false)
#         wk_begin, wk_end = self.get_week_begin_and_end_from_date(wk_start_date)
#         return self.user_signups_not_invited_in_period(wk_begin, wk_end, user_ids, clear_cache)
#       end

#       def user_signups_not_invited_in_month(month, user_ids=nil, clear_cache=false)
#         m_begin, m_end = self.get_month_begin_and_end_from_date(month)
#         return self.user_signups_not_invited_in_period(m_begin, m_end, user_ids, clear_cache)
#       end

#       def user_signups_not_invited_in_period(start_date, end_date, user_ids=nil, clear_cache=false)

#         data = []

#         start_date_str = start_date.strftime("%Y-%m-%d")
#         end_date_str = end_date.strftime("%Y-%m-%d")

#         clear_cache = true if end_date >= Date.today

#         results = Metrics::Tools.execute_cached_query(Metrics::Query.users_signups_not_invited_query(start_date_str, end_date_str, user_ids), clear_cache)
#         results.each do |row|
#           data << row[0] if !data.include?(row[0])
#         end

#         return data
#       end

#       ###
#       # ACTIVE USERS
#       ###
#       def active_users_in_day(metric, day, user_ids=nil, clear_cache=false)
#         return self.active_users_in_period(metric, day, day, user_ids, clear_cache)
#       end

#       def active_users_in_week(metric, wk_start_date, user_ids=nil, clear_cache=false)
#         wk_begin, wk_end = self.get_week_begin_and_end_from_date(wk_start_date)
#         return self.active_users_in_period(metric, wk_begin, wk_end, user_ids, clear_cache)
#       end

#       def active_users_in_month(metric, month, user_ids=nil, clear_cache=false)
#         m_begin, m_end = self.get_month_begin_and_end_from_date(month)
#         return self.active_users_in_period(metric, m_begin, m_end, user_ids, clear_cache)
#       end

#       def active_users_in_last_30_days(metric, day, user_ids=nil, clear_cache=false)
#         date_begin = day - 30.days
#         date_end = day
#         return self.active_users_in_period(metric, date_begin, date_end, user_ids, clear_cache)
#       end

#       def active_users_in_last_7_days(metric, day, user_ids=nil, clear_cache=false)
#         date_begin = day - 7.days
#         date_end = day
#         return self.active_users_in_period(metric, date_begin, date_end, user_ids, clear_cache)
#       end

#       def active_users_in_period(metric, start_date, end_date, user_ids=nil, clear_cache=false)

#         users = Set.new

#         start_date_str = start_date.strftime("%Y-%m-%d")
#         end_date_str = end_date.strftime("%Y-%m-%d")
#         clear_cache = true if end_date >= Date.today

#         results = Metrics::Tools.execute_cached_query(Metrics::Query.users_who_created_activity_query(start_date_str, end_date_str, user_ids), clear_cache)
#         result_user_ids = results.map { |r| r[0] }
#         users.merge(result_user_ids)

#         commented_results = Metrics::Tools.execute_cached_query(Metrics::Query.users_who_commented_query(start_date_str, end_date_str, user_ids), clear_cache)
#         result_user_ids = commented_results.map { |r| r[0] }
#         users.merge(result_user_ids)

#         liked_results = Metrics::Tools.execute_cached_query(Metrics::Query.users_who_liked_query(start_date_str, end_date_str, user_ids), clear_cache)
#         result_user_ids = liked_results.map { |r| r[0] }
#         users.merge(result_user_ids)

#         result_user_ids = logged_in_users.map { |r| r }
#         users.merge(result_user_ids)

#         # LOOSELY ACTIVE
#         if metric==:loosely_active
#           # Users who received sms/push
#           results = Metrics::Tools.execute_cached_query(Metrics::Query.users_received_notification_query(start_date_str, end_date_str, user_ids), clear_cache)
#           result_user_ids = results.map { |r| r[0] }
#           users.merge(result_user_ids)

#           # Users who actioned email
#           actioned_email_result = Metrics::Tools.execute_cached_query(Metrics::Query.users_received_email_notification_query(start_date_str, end_date_str, user_ids), clear_cache)
#           result_user_ids = actioned_email_result.map { |r| r[0] }
#           users.merge(result_user_ids)
#         end

#         return users
#       end


#       #####
#       # USER ACCOUNTING
#       #####
#       def user_growth_in_day(day, user_ids=nil, users_ever_active=nil, clear_cache=false)
#         return self.user_growth_in_period(day, day, user_ids, users_ever_active=nil, clear_cache)
#       end

#       def user_growth_in_week(wk_start_date, user_ids=nil, users_ever_active=nil, clear_cache=false)
#         wk_begin, wk_end = self.get_week_begin_and_end_from_date(wk_start_date)
#         return self.user_growth_in_period(wk_begin, wk_end, user_ids, users_ever_active=nil, clear_cache)
#       end

#       def user_growth_in_last_7_days(day, user_ids=nil, users_ever_active=nil, clear_cache=false)
#         date_begin = day - 7.days
#         date_end = day
#         return self.user_growth_in_period(date_begin, date_end, user_ids, users_ever_active=nil, clear_cache)
#       end

#       def user_growth_in_last_30_days(day, user_ids=nil, users_ever_active=nil, clear_cache=false)
#         date_begin = day - 30.days
#         date_end = day
#         return self.user_growth_in_period(date_begin, date_end, user_ids, users_ever_active=nil, clear_cache)
#       end

#       def user_growth_in_period(start_date, end_date, user_ids=nil, users_ever_active=nil, user_ids_previous=nil)

#         start_date_str = start_date.strftime("%Y-%m-%d")
#         end_date_str = end_date.strftime("%Y-%m-%d")
#         clear_cache = true if end_date >= Date.today

#         data = {}
#         users_ever_active = Set.new if users_ever_active.nil?

#         # How many new?
#         new_users = Metrics::Tools.execute_cached_query(Metrics::Query.users_signups_query(start_date_str, end_date_str, user_ids), clear_cache)
#         new_users = new_users.map { |r| r[0] }
#         data[:new] = Set.new(new_users)

#           # Invites

#         # Active
#           data[:active] = {}

#           # Core (Strictly)
#           core_active_users = self.active_users_in_period(:strictly_active, start_date, end_date, user_ids, clear_cache)
#           data[:active][:core] = core_active_users - data[:new]

#           # Casual (Loosely)
#           casual_active_users = self.active_users_in_period(:loosely_active, start_date, end_date, user_ids, clear_cache)
#           data[:active][:casual] = casual_active_users - core_active_users

#           # Total
#           data[:active][:total] = data[:active][:core] + data[:active][:casual]

#           period = (end_date - start_date).to_i
#           prev_start_date = start_date - period.days

#           # Calculate previous period
#           data[:previous_period] = {}

#           core_active_users = self.active_users_in_period(:strictly_active, prev_start_date, start_date, user_ids, clear_cache)
#           casual_active_users = self.active_users_in_period(:loosely_active, prev_start_date, start_date, user_ids, clear_cache)
#           data[:previous_period][:active] = core_active_users + casual_active_users

#           # How many resurrected (were not active in last period but now active)
#           data[:active][:resurrected] = (data[:active][:total] & users_ever_active) - data[:previous_period][:active]

#           # Remove resurrected from core and casual
#           data[:active][:core] -= data[:active][:resurrected]
#           data[:active][:casual] -= data[:active][:resurrected]

#           # How many went inactive (active before, now inactive)
#           data[:inactive] = data[:previous_period][:active] - data[:active][:total]

#         # Unsubscribed
#         unsubscribed = Metrics::Tools.execute_cached_query(Metrics::Query.users_unsubscribed_query(start_date_str, end_date_str, user_ids), clear_cache)
#         unsubscribed = unsubscribed.map { |r| r[0] }
#         data[:unsubscribed] = Set.new(unsubscribed)

#         return data
#       end


#       def daily_active_users(curr_day, user_ids=nil, clear_cache=false)

#         users = []
#         date_str = curr_day.strftime("%Y-%m-%d")

#         clear_cache = true if curr_day >= Date.today

#         # Activity Query
#         results = Metrics::Tools.execute_cached_query(Metrics::Query.users_who_created_activity_query(date_str, date_str, user_ids), clear_cache)
#         results.each do |row|
#           users << row[0] if !users.include?(row[0])
#         end

#         # Login Query
#         # active_login = $redis.get("metrics:" + dateStr + ":user_activity")
#         # active_login.each do |id|
#         #   users << id if !users.include?(id)
#         # end

#         return users
#       end


#       ###
#       # USERS WHO INVITED
#       ###
#       def users_invited_in_day(day, by_user_ids=nil, clear_cache=false)
#         return self.users_invited_in_period(day, day, by_user_ids, clear_cache)
#       end

#       def users_invited_in_week(wk_start_date, by_user_ids=nil, clear_cache=false)
#         wk_begin, wk_end = self.get_week_begin_and_end_from_date(wk_start_date)
#         return self.users_invited_in_period(wk_begin, wk_end, by_user_ids, clear_cache)
#       end

#       def users_invited_in_month(month, by_user_ids=nil, clear_cache=false)
#         m_begin, m_end = self.get_month_begin_and_end_from_date(month)
#         return self.users_invited_in_period(m_begin, m_end, by_user_ids, clear_cache)
#       end

#       def users_invited_in_period(start_date, end_date, by_user_ids=nil, clear_cache=false)

#         users = 0

#         start_date_str = start_date.strftime("%Y-%m-%d")
#         end_date_str = end_date.strftime("%Y-%m-%d")
#         clear_cache = true if end_date >= Date.today

#         results = Metrics::Tools.execute_cached_query(Metrics::Query.users_invited_by_query(start_date_str, end_date_str, by_user_ids), clear_cache)
#         results.each do |row|
#           users += row[0]
#         end

#         return users
#       end

#       ###
#       # ACCEPTING USERS
#       ###
#       def accepting_users_in_day(day, by_user_ids=nil, clear_cache=false)
#         return self.accepting_users_in_period(day, day, by_user_ids, clear_cache)
#       end

#       def accepting_users_in_week(week, by_user_ids=nil, clear_cache=false)
#         wk_begin, wk_end = self.get_week_begin_and_end_from_date(week)
#         return self.accepting_users_in_period(wk_begin, wk_end, by_user_ids, clear_cache)
#       end

#       def accepting_users_in_month(month, by_user_ids=nil, clear_cache=false)
#         m_begin, m_end = self.get_month_begin_and_end_from_date(month)
#         return self.accepting_users_in_period(m_begin, m_end, by_user_ids, clear_cache)
#       end

#       def accepting_users_in_period(start_date, end_date, by_user_ids=nil, clear_cache=false)
#         users = []

#         start_date_str = start_date.strftime("%Y-%m-%d")
#         end_date_str = end_date.strftime("%Y-%m-%d")
#         clear_cache = true if end_date >= Date.today

#         results = Metrics::Tools.execute_cached_query(Metrics::Query.accepting_users_query(start_date_str, end_date_str, by_user_ids), clear_cache)
#         results.each do |row|
#           users << row[0] if !users.include?(row[0])
#         end

#         return users
#       end


#       ###
#       # CONSUMING USERS
#       ###
#       def consuming_users(week, user_ids=nil, clear_cache=false)

#         wk_begin, wk_end = self.get_week_begin_and_end_from_date(week)
#         users = []

#         (0..6).each do |day_of_week|
#           curr_day = wk_begin + day_of_week
#           date_str = curr_day.strftime("%Y-%m-%d")

#           clear_cache = true if curr_day >= Date.today

#           # Users who received sms/push
#           results = Metrics::Tools.execute_cached_query(Metrics::Query.consuming_users(date_str, user_ids), clear_cache)
#           results.each do |row|
#             users << row[0] if !users.include?(row[0])
#           end
#         end

#         return users
#       end

#       ###
#       # ACTIVE USERS (REDIS QUERY)
#       ###
#       def getDailyActiveUsers(dateStr=nil)
#         dateStr = Time.new.strftime('%d-%m-%Y') if dateStr.nil?
#         $redis.bitcount("daily_active_users:" + dateStr)
#       end

#       def getWeeklyActiveUsers(wbDate=nil)
#         wbDate = Date.today if wbDate.nil?
#         fromDate = wbDate - (wbDate.cwday - 1)

#         @wau = self.getUniqueDailyActiveUsers(fromDate, 7)
#       end

#       def getMonthlyActiveUsers(wbDate=nil)
#         wbDate = Date.today if wbDate.nil?
#         @wau = self.getUniqueDailyActiveUsers(wbDate, 7)
#       end

#       def getUniqueDailyActiveUsers(fromDate, days)
#         key = "daily_active_users:"
#         days = days - 1

#         arBinStr = []

#         for i in 0..days do
#           dateKey = key + fromDate.strftime('%d-%m-%Y')
#           binkey = $redis.get(dateKey)
#           fromDate = fromDate + 1

#           next if binkey.nil?    

#           arBinStr << binkey.unpack("b*").first
#         end

#         if(arBinStr.length==0)
#           return 0
#         end

#         b1 = Bitset.from_s(arBinStr[0])
#         arBinStr.each do |b|
#           b2 = Bitset.from_s(b)
#           b1 = b1 | b2
#         end
#         b1.cardinality
#       end

#       ###
#       # USER FOLLOWS METRICS
#       # This data is taken from mixpanel
#       ###
#       def user_follows_data_between(week_begin, week_end, user_ids=nil, clear_cache=false)

#         series = []

#         user_follows = {}
#         user_downloads = {}
#         user_invited = {}

#         for i in week_begin..week_end
#           next if i != i.at_beginning_of_week 
          
#           key = i.strftime("%Y-%m-%d")
#           series << key
          
#           user_follows[key] = self.user_follows_in_week(i, user_ids, nil, clear_cache)
#           user_downloads[key] = self.user_downloads(i, user_follows[key], clear_cache)
#           user_invited[key] = self.user_invited(i, user_follows[key], clear_cache)
#         end

#         return_data = {
#           data: {
#             series: series.reverse,
#             values: {
#               faft_landings: {},# This is here to be compatibe for presenter
#               user_follows: user_follows,
#               user_downloads: user_downloads,
#               user_invited: user_invited
#             }
#           }
#         }

#         return return_data
#       end

#       ###
#       # USER FOLLOWED METRICS
#       # This data is taken from mixpanel
#       ###
#       def user_followed_data_between(week_begin, week_end, user_ids=nil, clear_cache=false)

#         series = []

#         faft_landings = {}
#         user_follows = {}
#         user_downloads = {}
#         user_invited = {}

#         invited_by_source = %w["TEAMFOLLOW"]

#         for i in week_begin..week_end
#           next if i != i.at_beginning_of_week 
          
#           puts i.strftime("%Y-%m-%d")

#           key = i.strftime("%Y-%m-%d")
#           series << key
          
#           faft_landings[key] = self.faft_landings_in_week(i, clear_cache)
#           user_follows[key] = self.user_follows_in_week(i, user_ids, invited_by_source, clear_cache)
#           user_downloads[key] = self.user_downloads(i, user_follows[key], clear_cache)
#           user_invited[key] = self.user_invited(i, user_follows[key], clear_cache)
#         end


#         return_data = {
#           data: {
#             series: series,
#             values: {
#               faft_landings: faft_landings,
#               user_follows: user_follows,
#               user_downloads: user_downloads,
#               user_invited: user_invited
#             }
#           }
#         }

#         return return_data
#       end

#       def user_follows_breakdown_data_between(week_begin, week_end, user_ids=nil, clear_cache=false)

#         series = []
#         media = []

#         values = {}

#         invited_by_source = %w["TEAMFOLLOW"]

#         for i in week_begin..week_end
#           key = i.strftime("%Y-%m-%d")
#           series << key
          
#           faft_landings = self.faft_landings_by_source(i)

#           faft_landings.each { |k,v| media << k unless media.include? k}

#           media.each do |medium|
#             values[medium] = {}
#             values[medium][key] = {}
#             values[medium][key][:faft_landings] = faft_landings.has_key?(medium) ? faft_landings[medium] : 0
#             values[medium][key][:user_follows] = self.user_follows_by_medium(medium, i, user_ids, invited_by_source, clear_cache)
#             values[medium][key][:user_downloaded] = self.user_downloads_by_medium(medium, i, values[medium][key][:user_follows], clear_cache)
#             values[medium][key][:user_invited] = self.user_invited_by_medium(medium, i, values[medium][key][:user_follows], clear_cache)
#           end
#         end

#         # Day-by-day breakdown
#         period_begin, first_wk_end = self.get_week_begin_and_end_from_date(week_begin)
#         last_wk_begin, period_end = self.get_week_begin_and_end_from_date(week_end)

#         dbd_series = []
#         dbd_values = {}
#         (period_begin..period_end).each do |day|
#           break if day > Date.today
#           key = day.strftime("%Y-%m-%d")
#           dbd_series << key
#           dbd_values[key] = {}
#           dbd_values[key][:faft_landings] = self.faft_landings_in_day(day)
#           dbd_values[key][:user_follows] = self.user_follows_in_day(day, user_ids, invited_by_source, clear_cache)
#           dbd_values[key][:user_downloaded] = self.user_downloads(day, dbd_values[key][:user_follows], clear_cache)
#           dbd_values[key][:user_invited] = self.user_invited(day, dbd_values[key][:user_follows], clear_cache)
#         end

#         return_data = {
#           data: {
#             series: series,
#             values: values
#           },
#           day_by_day_data: {
#             series: dbd_series,
#             values: dbd_values
#           }
#         }

#         return return_data
#       end

#       def faft_landings_in_day(day, clear_cache=false)
#         return self.faft_landings_in_period(day, day, clear_cache)
#       end

#       def faft_landings_in_week(week_start_date, clear_cache=false)
#         wk_begin, wk_end = self.get_week_begin_and_end_from_date(week_start_date)
#         return self.faft_landings_in_period(wk_begin, wk_end, clear_cache)
#       end

#       def faft_landings_in_period(start_date, end_date, clear_cache=false)
        
#         return 0 if start_date > Date.today

#         start_date_str = start_date.strftime("%Y-%m-%d")
#         end_date_str = end_date.strftime("%Y-%m-%d")

#         clear_cache = true if end_date >= Date.today

#         key = start_date.strftime("%Y-%m-%d")

#         # puts "#{(end_date - start_date).to_i} <= #{1}"
#         if (end_date - start_date).to_i == 0
#           period = "day"
#           period_in_days = 1.0
#         elsif (end_date - start_date) <= 7
#           period = "week"
#           period_in_days = 7.0
#         end

#         # puts "#{(Date.current - start_date)}"
#         interval = (((Date.current - start_date) / period_in_days) + 1).ceil

#         # puts "#{start_date} - #{end_date}"
#         # puts "Period #{period}"
#         # puts "Interval: #{interval}"

#         results = $mixpanel_client.request('events', {
#           event: ['Viewed Public Team Page', 'Viewed Unclaimed Team Page', 'Viewed Unclaimed Division Page'],
#           type: 'unique',
#           unit: period,
#           interval: interval
#         })

#         totals = []
#         results['data']['values'].each do |row|
#           totals << row[1][key]
#         end

#         total = 0
#         totals.each { |i| total += i unless i.nil? }

#         return total
#       end

#       def faft_landings_by_source(week)

#         wk_begin, wk_end = self.get_week_begin_and_end_from_date(week)
#         key = wk_begin.strftime("%Y-%m-%d")

#         weeks_since = ((Date.today - wk_begin).to_i / 7.0).ceil
#         totals = {}
        
#         ['Viewed Public Team Page', 'Viewed Unclaimed Team Page', 'Viewed Unclaimed Division Page'].each do |event|
          
#           results = $mixpanel_client.request('events/properties', {
#             event: event,
#             name: 'utm_medium',
#             type: 'unique',
#             unit: 'week',
#             interval: weeks_since
#           })

#           results['data']['values'].each do |k, row|
#             totals[k] = 0 if !totals.has_key?(k)
#             totals[k] += row[key]
#           end
#         end

#         return totals
#       end

#       def user_follows_in_day(day, user_ids=nil, invited_by_source=nil, clear_cache=false)
#         return self.user_follows_in_period(day, day, user_ids, invited_by_source, clear_cache)
#       end

#       def user_follows_in_week(week, user_ids=nil, invited_by_source=nil, clear_cache=false)
#         wk_begin, wk_end = self.get_week_begin_and_end_from_date(week)
#         return self.user_follows_in_period(wk_begin, wk_end, user_ids, invited_by_source, clear_cache)
#       end

#       def user_follows_in_period(start_date, end_date, user_ids=nil, invited_by_source=nil, clear_cache=false)

#         data = []

#         (start_date..end_date).each do |day|
#           date_str = day.strftime("%Y-%m-%d")

#           clear_cache = true if day >= Date.today

#           results = Metrics::Tools.execute_cached_query(Metrics::Query.users_follows_query(date_str, user_ids, invited_by_source), clear_cache)
#           results.each do |row|
#             data << row[0] if !data.include?(row[0])
#           end
#         end

#         return data
#       end

#       def user_follows_by_medium(medium, week, user_ids=nil, invited_by_source=nil, clear_cache=false)

#         wk_begin, wk_end = self.get_week_begin_and_end_from_date(week)
#         data = []

#         (0..6).each do |day_of_week|
#           curr_day = wk_begin + day_of_week
#           date_str = curr_day.strftime("%Y-%m-%d")

#           clear_cache = true if curr_day >= Date.today

#           results = Metrics::Tools.execute_cached_query(Metrics::Query.users_follows_by_medium_query(medium, date_str, user_ids, invited_by_source), clear_cache)
#           results.each do |row|
#             data << row[0] if !data.include?(row[0])
#           end
#         end

#         return data
#       end

#       def user_downloads(week,user_ids=nil,clear_cache=false)
#         data = []
#         results = Metrics::Tools.execute_cached_query(Metrics::Query.users_downloaded_query(user_ids), clear_cache)
#         results.each do |row|
#           data << row[0] if !data.include?(row[0])
#         end

#         return data
#       end

#       def user_downloads_by_medium(medium, week, user_ids=nil, clear_cache=false)

#         wk_begin, wk_end = self.get_week_begin_and_end_from_date(week)
#         data = []

#         (0..6).each do |day_of_week|
#           curr_day = wk_begin + day_of_week
#           date_str = curr_day.strftime("%Y-%m-%d")

#           clear_cache = true if curr_day >= Date.today

#           results = Metrics::Tools.execute_cached_query(Metrics::Query.users_downloaded_by_medium_query(medium, user_ids), clear_cache)
#           results.each do |row|
#             data << row[0] if !data.include?(row[0])
#           end
#         end

#         return data
#       end

#       def user_invited(week, user_ids=nil, clear_cache=false)

#         data = []
#         results = Metrics::Tools.execute_cached_query(Metrics::Query.users_invited_query(user_ids), clear_cache)
#         results.each do |row|
#           data << row[0] if !data.include?(row[0])
#         end

#         return data
#       end

#       def user_invited_by_medium(medium, week, user_ids=nil, clear_cache=false)

#         wk_begin, wk_end = self.get_week_begin_and_end_from_date(week)
#         data = []

#         (0..6).each do |day_of_week|
#           curr_day = wk_begin + day_of_week
#           date_str = curr_day.strftime("%Y-%m-%d")

#           clear_cache = true if curr_day >= Date.today

#           results = Metrics::Tools.execute_cached_query(Metrics::Query.users_invited_by_medium_query(medium, user_ids), clear_cache)
#           results.each do |row|
#             data << row[0] if !data.include?(row[0])
#           end
#         end

#         return data
#       end


#       def user_influence_on_follows(week)
#         # Get all users who have followed
#         user_ids = self.user_follows_in_week(week)
#         users = User.find(user_ids, :include => :team_roles)

#         data = []

#         users.each do |user|

#           downloaded_app = user.mobile_devices.empty? ? false : user.mobile_devices.first.created_at

#           # get team(s)
#           team_role = user.team_roles.first

#           # how many people have followed since
#           members = TeamAnalysis.number_members(:after, team_role.team_id, user.created_at.strftime("%Y-%m-%d"))

#           team_members = []
#           members.each do |m_data|
#             next if m_data[0]==user.id
#             team_members << User.find(m_data[0])
#           end

#           # puts "User: #{user.id} Members: #{team_members.size}"

#           invited_by_user = []
#           team_members.each do |iu|
#             invited_by_user << iu if iu.invited_by_source_user_id==user.id
#           end

#           user_data = {
#             :user => user,
#             :team_id => team_role.team_id,
#             :downloaded_app => downloaded_app,
#             :team_members => team_members,
#             :invited_members => invited_by_user,
#           }

#           data << user_data
#         end

#         data
#       end


#       def followed_faft_team_ids
#         Metrics::Tools.execute_cached_query(Metrics::Query.users_followed_faft_team_ids(nil), true)
#       end

#       def get_week_begin_and_end(week, year)
#         wk_begin = Date.commercial(year, week, 1)
#         wk_end = Date.commercial(year, week, 7)

#         return wk_begin, wk_end
#       end

#       def get_week_begin_and_end_from_date(date)
#         wk_begin = date.at_beginning_of_week
#         wk_end = date.at_end_of_week

#         return wk_begin, wk_end
#       end

#       def get_month_begin_and_end(month, year)
#         m_begin = Date.civil(year, month, 1)
#         m_end = Date.civil(year, month, -1)

#         return m_begin, m_end
#       end

#       def get_month_begin_and_end_from_date(month)
#         m_begin = month.at_beginning_of_month
#         m_end = month.at_end_of_month

#         return m_begin, m_end
#       end

#       def get_week_key(date)
#         return date.at_end_of_week.strftime("%Y") + date.strftime("-%V")
#       end
# 		end
# 	end
# end