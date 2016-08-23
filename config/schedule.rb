# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever





#######
# PLEASE MAKE SURE YOU ADD ":roles => [:cron]" TO EVERY BLOCK YOU ADD
#  OR ALL YOUR CRONS WILL BE RUN ON VARIOUS MACHINES! TS
###

every 15.minutes, :roles => [:cron] do
  rake "emails:scheduled_event_reminders_auto" #This task is dependant on the 15 minute cycle
  rake "emails:weekly_event_schedule" #This task is dependant on the 15 minute cycle
end

every 24.hours, :roles => [:cron] do
	# mark inactive iOS devices as such
	rake "urbanairship:process_deactivations"

	# Warm sitemap caches
	rake "sitemap_cache:warm_faft_teams"

end

every :day, :at => '1am', :roles => [:cron] do
  rake "metrics_cache:warm_rfu_dashboard"
end
