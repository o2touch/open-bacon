require 'clockwork'
require './config/boot'
require './config/environment'

module Clockwork
  handler do |job|
    puts "Running #{job}"
  end

  every(15.minutes, 'Monday morning check', tz: 'UTC') { TriggerService.delay.weekly_event_schedule }
  every(15.minutes, 'Reminder emails', tz: 'UTC') { TriggerService.delay.scheduled_user_event_reminders(Time.now.utc, 15) }
end