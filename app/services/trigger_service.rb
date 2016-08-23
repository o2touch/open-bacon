class TriggerService
  class << self

    SECONDS_IN_DAY = 1.day.to_i

    # This should be called every 15 minutes when it could be monday morning somewhere
    def weekly_event_schedule
      utc_time = Time.now.utc

      # find TZs where it's ~08:45 on a Monday morning
      matching_tzs = TriggerService.monday_morning_timezones(utc_time)

      # create app events for each TZ
      robot = User.find(1)
      matching_tzs.each do |tz|
        next unless User.where(time_zone: tz.name).count > 0

        meta_data = { 
          time_zone: tz.name, 
          processor: 'Ns2::Processors::ScheduledNotificationsProcessor', 
          utc_run_time: utc_time
        }
        # robot is dummy data, as this doesn't quite fit our model.
        AppEventService.create(robot, robot, "weekly_event_schedule", meta_data)
      end
    end

    def monday_morning_timezones(utc_time=Time.now.utc)
       # find TZs where it's ~08:45 on a Monday morning
      matching_tzs = [] 
      TZInfo::Timezone.all.each do |tz|
        local_time = tz.utc_to_local(utc_time)

        next unless local_time.wday == 1 # monday
        next unless local_time.hour == 8 # 8 am
        next unless local_time.min >= 45 && local_time.min <= 59
        matching_tzs << tz 
      end
      matching_tzs
    end

    def next_game_sms
      # create app events for each TZ
      TriggerService.monday_morning_timezones.each do |tz|
        User.where(time_zone: tz.name).each do |user|
          user.team_roles.select { |team_role| !team_role.obj.events_next_week.empty? }.map(&:obj).uniq.each do |team|
            event = team.events_next_week.first

            meta_data = { 
              processor: 'Ns2::Processors::ScheduledNotificationsProcessor'
            }
            AppEventService.create(event, user, "weekly_next_game", meta_data)
          end
        end
      end
    end


    def scheduled_user_event_reminders(time_job_started=Time.now, job_interval=15, events=nil)
      # SR - When we are confident sidekiq won't fall over this can all be removed in favour of scheduled sidekiq jobs at the time the 
      # notification is created. 

      users_to_remind = {}

      # Moved this query into here from rake task, because it is tightly coupled with the logic of this function: time range and status of events
      # Let's restrict the # of events we're dealing with for a small amount of optimisation
      events = Event.where("time > ?", time_job_started).where("time < ?", (time_job_started + 7.days)).where("status = ?", 0) if events.nil?
      events_to_process = events.reject {|e| (e.time < time_job_started || e.is_cancelled? || e.type == "DemoEvent")}

      # Iterate through the events and build a list of users who need reminders
      events_to_process.each do |event|
        begin
          Rails.logger.info "Processing Event #{event.id}"
          local_time_job_started = time_job_started.in_time_zone(event.time_zone)

          next unless reminders_need_to_be_sent?(event, local_time_job_started, job_interval)

          # Yes, lets add the available users to the to_remind list
          self.get_available_users(event).each do |user_id|
            users_to_remind[user_id].nil? ? users_to_remind[user_id] = [event.id] : users_to_remind[user_id] << event.id 
          end

        rescue Exception => e
          Rails.logger.warn "Something went wrong: #{e.message}: #{e.backtrace.to_yaml}"
        end 
      end

      # Trigger a reminder event for each user
      users_to_remind.each_pair do |user_id, event_ids|
        EventNotificationService.scheduled_event_reminder_triggered(user_id, event_ids)
      end
    end

    # is it the right time to send reminders for this event and do reminders need to be sent today?
    def reminders_need_to_be_sent?(event, local_time_job_started, job_interval)
      # Could put other logic here...
      return self.time_to_remind?(event, local_time_job_started, job_interval) && self.reminders_sent_today?(event, local_time_job_started)
    end

    # Is it time to remind
    def time_to_remind?(event, time_start, time_end)
      hour_in_day_to_send = get_team_config_setting_for_event(event, TeamConfigKeyEnum::AUTOMATED_REMINDER_SCHEDULED_HOUR)
      min_in_day_to_send = get_team_config_setting_for_event(event, TeamConfigKeyEnum::AUTOMATED_REMINDER_SCHEDULED_MINUTE)

      return false if min_in_day_to_send.nil? || hour_in_day_to_send.nil? # settings can return nil

      # time_start is within the hour and minute scheduled
      return (time_start.hour == hour_in_day_to_send && (min_in_day_to_send >= time_start.min && min_in_day_to_send < (time_start.min + time_end)))
    end

    # Do reminders need to be sent today
    def reminders_sent_today?(event, today=Time.now)
      days = 1..7

      # Check Team Reminder settings
      automated_reminder_settings = get_team_config_setting_for_event(event, TeamConfigKeyEnum::AUTOMATED_REMINDER_SETTINGS)
      return false if automated_reminder_settings.nil? # Could be no team on event

      automated_reminder_settings.each do |days_prior_to_event_start|
        if days.include?(days_prior_to_event_start.to_i)
          day_to_check = today + (days_prior_to_event_start * 1.day)
          # Check if event lies on the day we're checking
          return true if (day_to_check.beginning_of_day..day_to_check.end_of_day).cover?(event.time_local)
        end
      end

      false
    end

    # Get available users for an event
    def get_available_users(event)
      event.teamsheet_entries_available.collect{|tse| tse.user_id.to_s}
    end

    def get_team_config_setting_for_event(event, key)
      return nil if event.team.nil?
      setting = event.team.team_config[key]
      if setting.nil?
        setting = event.is_league_event? ? event.team.league_config(event.fixture.division)[key] : DEFAULT_TEAM_CONFIG[key]
      end
      setting
    end

  end
end
