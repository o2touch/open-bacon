require 'spec_helper'

describe 'TriggerService' do

	describe '#weekly_event_schedule' do
		it 'should only create app events for TZs when 08:45 - 08:59 on a Monday morning' do
			FactoryGirl.create(:user, time_zone: 'Pacific/Chatham')
			FactoryGirl.create(:user, time_zone: 'NZ-CHAT')

			tz = TZInfo::Timezone.get('Pacific/Chatham') # a fucked up tz 
			local_time = Time.new(2013, 10, 14, 8, 45, 0) # a monday morning
			utc_time = tz.local_to_utc(local_time)
			Time.stub(now: utc_time)
				
			robot = User.find(1)
      md = { time_zone: 'Pacific/Chatham', processor: 'Ns2::Processors::ScheduledNotificationsProcessor', utc_run_time: kind_of(Time) }
			AppEventService.should_receive(:create).with(robot, robot, "weekly_event_schedule", md)
      md = { time_zone: 'NZ-CHAT', processor: 'Ns2::Processors::ScheduledNotificationsProcessor', utc_run_time: kind_of(Time) }
			AppEventService.should_receive(:create).with(robot, robot, "weekly_event_schedule", md)

			TriggerService.weekly_event_schedule
		end
	end

	describe '#next_game_sms' do
		it 'should send sms to users if their teams have evented scheduled for the following week' do
			user = FactoryGirl.create(:user, time_zone: 'NZ-CHAT')

			team_with_events_next_week = mock_model(Team)
			event = mock_model(Event)
			team_with_events_next_week.stub(:events_next_week).and_return([event])
			
			team_without_events_next_week = mock_model(Team)
			team_without_events_next_week.stub(:events_next_week).and_return([])

			trs = []
			[team_without_events_next_week, team_with_events_next_week].each do |team|
				tr = FactoryGirl.build(:poly_role, :user => user, :obj => team, :role_id => PolyRole::PLAYER)
				tr.stub(:touch_via_cache).and_return(true)
				trs << tr
			end
			user.stub(:team_roles).and_return(trs)	

			User.stub(:where).with(time_zone: user.time_zone).and_return([user])

			time_zone = double('time zone')
			time_zone.stub(:name).and_return(user.time_zone)

			TriggerService.stub(:monday_morning_timezones).and_return([time_zone])

			AppEventService.should_receive(:create).with(event, user, "weekly_next_game", {:processor=>"Ns2::Processors::ScheduledNotificationsProcessor"})

			TriggerService.next_game_sms
		end
	end

	# no longer used. To remove.
	# describe '#invite_reminders' do
	# 	it 'should send invite reminders where event.time > x days && event.time < x days + 15 mins' do
	# 		events = []
	# 		(0..2).each_with_index do |i|
	# 			e = double("e#{i}")
	# 			e.stub(id: i)
	# 			e.stub(should_notify?: true)
	# 			e.stub(response_by: 1)
	# 			# slightly mental, but means we can keep it in the loop and get one
	# 			#  before, one in, and one after
	# 			e.stub(time: (6.days.from_now - 1.minutes) + i*10.minutes)
	# 			events << e
	# 		end

	# 		EventNotificationService.should_receive(:send_invitation_reminders).once.with(events[1], true)

	# 		TriggerService.invite_reminders(events)
	# 	end

	# 	it 'works for the next 7 days, but not after' do
	# 		events = []
	# 		(0..9).each_with_index do |i|
	# 			e = double("e#{i}")
	# 			e.stub(id: i)
	# 			e.stub(should_notify?: true)
	# 			e.stub(response_by: 1)
	# 			# slightly mental, but means we can keep it in the loop and get one
	# 			#  before, one in, and one after
	# 			e.stub(time: (12.minutes.from_now) + i.days)
	# 			events << e
	# 		end
			
			
	# 		EventNotificationService.should_receive(:send_invitation_reminders).exactly(7).times

	# 		TriggerService.invite_reminders(events)
	# 	end
	# end

	describe 'scheduled_event_reminders' do

		# Helper method to provide team mock
		def get_team_model(reminder_settings, scheduled_hour)
			team = mock_model(Team)
			team.stub(:id).and_return(1)
			team.stub(:team_config).and_return({
				LeagueConfigKeyEnum::AUTOMATED_REMINDER_SETTINGS => reminder_settings,
				TeamConfigKeyEnum::AUTOMATED_REMINDER_SCHEDULED_HOUR => scheduled_hour
			})
			team
		end

		let(:tse_available) { mock_model(TeamsheetEntry, :user_id => "1000", :response_status => InviteResponseEnum::AVAILABLE) }

		it 'should send a reminder when an event is one day away' do
			team = get_team_model([1], 8)
			now = Time.new(2018,4,1,8,0,0, "-07:00")

			events = (1..3).map do |i|
				e = FactoryGirl.build(:event)
				e.stub(:team).and_return(team)
				# e.stub(:id).and_return(i)
				e.stub(:is_cancelled?).and_return(false)
				e.stub(:is_postponed?).and_return(false)
				e.stub(:type).and_return(Event.name)			
				e.stub(:time).and_return(now + (i * 1.day) + 1.minute + 8.hours)
				e.stub(:time_local).and_return(now + (i * 1.day) + 1.minute)
				e.stub(:time_zone).and_return("America/Los_Angeles")
				e.stub(:teamsheet_entries_available).and_return([tse_available])
				e
			end
			
			EventNotificationService.should_receive(:scheduled_event_reminder_triggered).once.with(tse_available.user_id, [events[0].id])
			TriggerService.scheduled_user_event_reminders(now, 15, events)
		end

		it 'should send a reminder when two events are one day away' do
			team = get_team_model([1], 8)
			now = Time.new(2018,4,1,8,0,0, "-07:00")

			events = (2..4).map do |i|
				# e = mock_model(Event)
				e = FactoryGirl.build(:event)
				e.stub(:team).and_return(team)
				e.stub(:id).and_return(i)
				e.stub(:is_cancelled?).and_return(false)
				e.stub(:is_postponed?).and_return(false)
				e.stub(:type).and_return(Event.name)			
				e.stub(:time).and_return(now + (i * 1.day) + 1.minute + 7.hours)
				e.stub(:time_local).and_return(now + (i * 1.day) + 1.minute)
				e.stub(:time_zone).and_return("America/Los_Angeles")
				e.stub(:teamsheet_entries_available).and_return([tse_available])
				e
			end

			e1 = FactoryGirl.build(:event)
			e1.stub(:team).and_return(team)
			e1.stub(:id).and_return(0)
			e1.stub(:is_cancelled?).and_return(false)
			e1.stub(:is_postponed?).and_return(false)
			e1.stub(:type).and_return(Event.name)			
			e1.stub(:time).and_return(now + 1.day + 1.minute + 8.hours)
			e1.stub(:time_local).and_return(now + 1.day + 1.minute)
			e1.stub(:time_zone).and_return("America/Los_Angeles")
			e1.stub(:teamsheet_entries_available).and_return([tse_available])
			events << e1

			e2 = FactoryGirl.build(:event)
			e2.stub(:team).and_return(team)
			e2.stub(:id).and_return(1)
			e2.stub(:is_cancelled?).and_return(false)
			e2.stub(:is_postponed?).and_return(false)
			e2.stub(:type).and_return(Event.name)			
			e2.stub(:time).and_return(now + 1.day + 1.minute + 8.hours)
			e2.stub(:time_local).and_return(now + 1.day + 3.hours)
			e2.stub(:time_zone).and_return("America/Los_Angeles")
			e2.stub(:teamsheet_entries_available).and_return([tse_available])
			events << e2
			
			EventNotificationService.should_receive(:scheduled_event_reminder_triggered).once.with(tse_available.user_id, [e1.id, e2.id])
			TriggerService.scheduled_user_event_reminders(now, 15, events)
		end

		it 'should ignore cancelled events' do
			now = Time.new(2018,4,1,8,0,0, "-07:00")

			e = mock_model(Event)
			e.stub(:id).and_return(1)
			e.stub(:is_cancelled?).and_return(true)
			e.stub(:is_postponed?).and_return(false)
			e.stub(:type).and_return(Event.name)			
			e.stub(:time).and_return(now + 1.day + 1.minute)
			e.stub(:time_local).and_return(now + (1.day) + 1.minute)
			e.stub(:time_zone).and_return("America/Los_Angeles")

			events = [e]
			
			EventNotificationService.should_receive(:scheduled_event_reminder_triggered).exactly(0).times.with(any_args())
			TriggerService.scheduled_user_event_reminders(now, 15, events)
		end

		it 'should ignore postponed events' do
			now = Time.new(2018,4,1,8,0,0, "-07:00")

			e = mock_model(Event)
			e.stub(:id).and_return(1)
			e.stub(:is_cancelled?).and_return(false)
			e.stub(:is_postponed?).and_return(true)
			e.stub(:type).and_return(Event.name)			
			e.stub(:time).and_return(now + 1.day + 1.minute)
			e.stub(:time_local).and_return(now + (1.day) + 1.minute)
			e.stub(:time_zone).and_return("America/Los_Angeles")

			events = [e]
			
			EventNotificationService.should_receive(:scheduled_event_reminder_triggered).exactly(0).times.with(any_args())
			TriggerService.scheduled_user_event_reminders(now, 15, events)
		end

		it 'should ignore events with type DemoEvent' do
			now = Time.new(2018,4,1,8,0,0, "-07:00")

			e = mock_model(Event)
			e.stub(:id).and_return(1)
			e.stub(:is_cancelled?).and_return(false)
			e.stub(:is_postponed?).and_return(false)
			e.stub(:type).and_return(DemoEvent.name)			
			e.stub(:time).and_return(now + 1.day + 1.minute)
			e.stub(:time_local).and_return(now + (1.day) + 1.minute)
			e.stub(:time_zone).and_return("America/Los_Angeles")

			events = [e]
			
			EventNotificationService.should_receive(:scheduled_event_reminder_triggered).exactly(0).times.with(any_args())
			TriggerService.scheduled_user_event_reminders(now, 15, events)
		end

		it 'should ignore events with time < job_start_time' do
			now = Time.new(2018,4,1,8,0,0, "-07:00")

			e = mock_model(Event)
			e.stub(:id).and_return(1)
			e.stub(:is_cancelled?).and_return(false)
			e.stub(:is_postponed?).and_return(false)
			e.stub(:type).and_return(DemoEvent.name)			
			e.stub(:time).and_return(now - 1.day)
			e.stub(:time_zone).and_return("America/Los_Angeles")

			events = [e]
			
			EventNotificationService.should_receive(:scheduled_event_reminder_triggered).exactly(0).times.with(any_args())
			TriggerService.scheduled_user_event_reminders(now, 15, events)
		end

		it 'should not send reminders if the days prior to value is > 7' do
			team = get_team_model([8], 8)
			now = Time.new(2018,4,1,8,0,0, "-07:00")

			e = mock_model(Event)
			e.stub(:id).and_return(1)
			e.stub(:team).and_return(team)
			e.stub(:is_cancelled?).and_return(false)
			e.stub(:is_postponed?).and_return(false)
			e.stub(:type).and_return(DemoEvent.name)			
			e.stub(:time).and_return(now + 1.day + 1.minute)
			e.stub(:time_local).and_return(now + 1.day + 1.minute)
			e.stub(:time_zone).and_return("America/Los_Angeles")

			events = [e]
			
			EventNotificationService.should_receive(:scheduled_event_reminder_triggered).exactly(0).times.with(any_args())
			TriggerService.scheduled_user_event_reminders(now, 15, events)
		end

		it 'should not send reminders if the days prior to value is < 1' do
			team = get_team_model([0], 8)
			now = Time.new(2018,4,1,8,0,0, "-07:00")

			e = mock_model(Event)
			e.stub(:id).and_return(1)
			e.stub(:team).and_return(team)
			e.stub(:is_cancelled?).and_return(false)
			e.stub(:is_postponed?).and_return(false)
			e.stub(:type).and_return(DemoEvent.name)			
			e.stub(:time).and_return(now + 1.day + 1.minute)
			e.stub(:time_local).and_return(now + 1.day + 1.minute)
			e.stub(:time_zone).and_return("America/Los_Angeles")

			events = [e]
			
			EventNotificationService.should_receive(:scheduled_event_reminder_triggered).exactly(0).times.with(any_args())
			TriggerService.scheduled_user_event_reminders(now, 15, events)
		end

		it 'should send reminders if the days prior to value is in the range 1..7' do
			team = get_team_model([4], 8)

			now = Time.new(2018,4,1,8,0,0,"-07:00")

			e = FactoryGirl.build(:event)
			e.stub(:id).and_return(1)
			e.stub(:team).and_return(team)
			e.stub(:is_cancelled?).and_return(false)
			e.stub(:is_postponed?).and_return(false)
			e.stub(:type).and_return(Event.name)			
			e.stub(:time).and_return(now + 4.day + 1.minute)
			e.stub(:time_local).and_return(now + 4.day + 1.minute)
			e.stub(:teamsheet_entries_available).and_return([tse_available])

			events = [e]
			
			EventNotificationService.should_receive(:scheduled_event_reminder_triggered).once.with(tse_available.user_id, [events[0].id])
			TriggerService.scheduled_user_event_reminders(now, 15, events)
		end

		it 'should send a single reminder given multiple days prior to values' do
			team = get_team_model([1,2,3], 8)
			now = Time.new(2018,4,1,8,0,0,"-07:00")

			e = FactoryGirl.build(:event)
			e.stub(:id).and_return(1)
			e.stub(:team).and_return(team)
			e.stub(:is_cancelled?).and_return(false)
			e.stub(:is_postponed?).and_return(false)
			e.stub(:type).and_return(Event.name)			
			# This event should trigger a reminder due the AUTOMATED_REMINDER_SETTINGS value 2
			e.stub(:time).and_return(now + 2.day + 1.minute + 8.hours)
			e.stub(:time_local).and_return(now + 2.day + 1.minute)
			e.stub(:time_zone).and_return("America/Los_Angeles")
			e.stub(:teamsheet_entries_available).and_return([tse_available])

			events = [e]
			
			EventNotificationService.should_receive(:scheduled_event_reminder_triggered).once.with(tse_available.user_id, [e.id])
			TriggerService.scheduled_user_event_reminders(now, 15, events)
		end

		it 'should not send a single reminder if no days prior to values match' do
			team = get_team_model([1,3,4], 8)
			now = Time.new(2018,4,1,8,0,0,"-07:00")

			e = FactoryGirl.build(:event)
			e.stub(:id).and_return(1)
			e.stub(:team).and_return(team)
			e.stub(:is_cancelled?).and_return(false)
			e.stub(:is_postponed?).and_return(false)
			e.stub(:type).and_return(Event.name)			
			e.stub(:time).and_return(now + 2.day + 1.minute)

			events = [e]
			
			EventNotificationService.should_receive(:scheduled_event_reminder_triggered).exactly(0).times.with(any_args())
			TriggerService.scheduled_user_event_reminders(now, 15, events)
		end

		it 'should not send a single reminder if the time to the event is > (days piror + job_interval)' do
			team = get_team_model([1,2,4], 8)

			now = Time.new(2018,4,1,8,0,0,"-07:00")
			job_interval = 20

			e = FactoryGirl.build(:event)
			e.stub(:id).and_return(1)
			e.stub(:team).and_return(team)
			e.stub(:is_cancelled?).and_return(false)
			e.stub(:is_postponed?).and_return(false)
			e.stub(:type).and_return(Event.name)			
			e.stub(:time).and_return(now + 2.day + (job_interval * 1.minute) + 1.second)

			events = [e]
			
			EventNotificationService.should_receive(:scheduled_event_reminder_triggered).exactly(0).times.with(any_args())
			TriggerService.scheduled_user_event_reminders(now, job_interval, events)
		end

		context "when a user is not available" do

			let(:tse_available) {mock_model(TeamsheetEntry, :user_id => "1000", :response_status => InviteResponseEnum::AVAILABLE)}
			let(:tse_unavailable) {mock_model(TeamsheetEntry, :user_id => "1001", :response_status => InviteResponseEnum::UNAVAILABLE)}

			it "does not send a reminder to that user" do

				team = get_team_model([4],8)
				now = Time.new(2018,4,1,8,0,0,"-07:00")

				e = FactoryGirl.build(:event)
				e.stub(:id).and_return(1)
				e.stub(:team).and_return(team)
				e.stub(:is_cancelled?).and_return(false)
				e.stub(:is_postponed?).and_return(false)
				e.stub(:type).and_return(Event.name)			
				e.stub(:time).and_return(now + 4.day + 1.minute)
				e.stub(:time_local).and_return(now + 4.day + 1.minute)
				e.stub(:teamsheet_entries_available).and_return([tse_available])

				events = [e]
				
				EventNotificationService.should_receive(:scheduled_event_reminder_triggered).once.with(tse_available.user_id, [events[0].id])
				EventNotificationService.should_not_receive(:scheduled_event_reminder_triggered).with(tse_unavailable.user_id, [events[0].id])
				TriggerService.scheduled_user_event_reminders(now, 15, events)
			end
		  
		end


		it "does not send a reminder twice" do
	
			team = get_team_model([1],8)
			now = Time.new(2018,4,1,8,0,0, "-07:00")

			events = (1..3).map do |i|
				e = FactoryGirl.build(:event)
				e.stub(:team).and_return(team)
				e.stub(:id).and_return(i)
				e.stub(:is_cancelled?).and_return(false)
				e.stub(:is_postponed?).and_return(false)
				e.stub(:type).and_return(Event.name)			
				e.stub(:time).and_return(now + (i * 1.day) + 1.minute + 8.hours)
				e.stub(:time_local).and_return(now + (i * 1.day) + 1.minute)
				e.stub(:time_zone).and_return("America/Los_Angeles")
				e.stub(:teamsheet_entries_available).and_return([tse_available])
				e
			end
			
			EventNotificationService.should_receive(:scheduled_event_reminder_triggered).once.with(tse_available.user_id, [events[0].id])
			TriggerService.scheduled_user_event_reminders(now, 15, events)

			# Simulate it running again 15 minutes later
			now = Time.new(2018,4,1,8,15,0, "-07:00")
			TriggerService.scheduled_user_event_reminders(now, 15, events)
		end

		context "when shouldn't send because of local time" do

			it "does not send a reminder" do
				
				team = get_team_model([1],8)
				now = Time.new(2018,4,1,1,0,0, "-07:00")

				events = (1..3).map do |i|
					e = FactoryGirl.build(:event)
					e.stub(:team).and_return(team)
					e.stub(:id).and_return(i)
					e.stub(:is_cancelled?).and_return(false)
					e.stub(:is_postponed?).and_return(false)
					e.stub(:type).and_return(Event.name)			
					e.stub(:time).and_return(now + (i * 1.day) + 1.minute + 8.hours)
					e.stub(:time_local).and_return(now + (i * 1.day) + 1.minute)
					e.stub(:time_zone).and_return("America/Los_Angeles")
					e.stub(:teamsheet_entries_available).and_return([tse_available])
					e
				end
				
				EventNotificationService.should_not_receive(:scheduled_event_reminder_triggered).with(tse_available.user_id, [events[0].id])
				TriggerService.scheduled_user_event_reminders(now, 15, events)
			end			
		  
		end

		context "when shouldn't send because of local time" do

			it "does not send a reminder" do
				team = get_team_model([1],8)

				now = Time.new(2018,4,1,8,0,0, "-07:00")

				e1 = FactoryGirl.build(:event)
				e1.stub(:team).and_return(team)
				e1.stub(:id).and_return(1)
				e1.stub(:is_cancelled?).and_return(false)
				e1.stub(:is_postponed?).and_return(false)
				e1.stub(:type).and_return(Event.name)			
				e1.stub(:time).and_return(now + 1.day + 1.minute + 8.hours)
				e1.stub(:time_local).and_return(now + 1.day + 1.minute)
				e1.stub(:time_zone).and_return("America/Los_Angeles")
				e1.stub(:teamsheet_entries_available).and_return([tse_available])

				e2 = FactoryGirl.build(:event)
				e2.stub(:team).and_return(team)
				e2.stub(:id).and_return(2)
				e2.stub(:is_cancelled?).and_return(false)
				e2.stub(:is_postponed?).and_return(false)
				e2.stub(:type).and_return(Event.name)			
				e2.stub(:time).and_return(now + 1.day + 1.minute + 8.hours)
				e2.stub(:time_local).and_return(now.in_time_zone("Asia/Bangkok") + 1.day + 1.minute)
				e2.stub(:time_zone).and_return("Asia/Bangkok")
				e2.stub(:teamsheet_entries_available).and_return([tse_available])
				
				events = [e1,e2]
				
				EventNotificationService.should_receive(:scheduled_event_reminder_triggered).with(tse_available.user_id, [events[0].id])
				EventNotificationService.should_not_receive(:scheduled_event_reminder_triggered).with(tse_available.user_id, [events[1].id])
				TriggerService.scheduled_user_event_reminders(now, 15, events)
			end			
		  
		end

		it "does not send a reminder more than once" do
			team = get_team_model([1], 8)
			now = Time.new(2018,4,1,8,0,0, "-07:00")

			events = (1..3).map do |i|
				e = FactoryGirl.build(:event)
				e.stub(:team).and_return(team)
				e.stub(:id).and_return(i)
				e.stub(:is_cancelled?).and_return(false)
				e.stub(:is_postponed?).and_return(false)
				e.stub(:type).and_return(Event.name)			
				e.stub(:time).and_return(now + (i * 1.day) + 1.minute + 8.hours)
				e.stub(:time_local).and_return(now + (i * 1.day) + 1.minute)
				e.stub(:time_zone).and_return("America/Los_Angeles")
				e.stub(:teamsheet_entries).and_return(
					[tse_available]
				)
				e.stub(:teamsheet_entries_available).and_return([tse_available])
				e
			end
			
			EventNotificationService.should_receive(:scheduled_event_reminder_triggered).once.with(tse_available.user_id, [events[0].id])
			TriggerService.scheduled_user_event_reminders(now, 15, events)

			# Simulate it running again 15 minutes later
			now = Time.new(2018,4,1,8,15,0, "-07:00")
			TriggerService.scheduled_user_event_reminders(now, 15, events)

			# Simulate it running again 30 minutes later
			now = Time.new(2018,4,1,8,30,0, "-07:00")
			TriggerService.scheduled_user_event_reminders(now, 15, events)

			# Simulate it running again 45 minutes later
			now = Time.new(2018,4,1,8,45,0, "-07:00")
			TriggerService.scheduled_user_event_reminders(now, 15, events)
		end

	end	

	describe "#time_to_remind?" do
		context "with a 15 minute job interval" do

			let(:e) { double(Event) }
			let(:job_interval) { 15 }

			it "returns true at start of job" do
				now = Time.new(2018,4,1,8,0,0, "-07:00")
				hour = 8
				minute = 0

				TriggerService.stub(:get_team_config_setting_for_event).with(e, TeamConfigKeyEnum::AUTOMATED_REMINDER_SCHEDULED_HOUR).and_return(hour)
				TriggerService.stub(:get_team_config_setting_for_event).with(e, TeamConfigKeyEnum::AUTOMATED_REMINDER_SCHEDULED_MINUTE).and_return(minute)

				TriggerService.time_to_remind?(e, now, job_interval).should be_true
			end

			it "returns true in the middle of the job" do
				now = Time.new(2018,4,1,8,0,0, "-07:00")
				hour = 8
				minute = 9

				TriggerService.stub(:get_team_config_setting_for_event).with(e, TeamConfigKeyEnum::AUTOMATED_REMINDER_SCHEDULED_HOUR).and_return(hour)
				TriggerService.stub(:get_team_config_setting_for_event).with(e, TeamConfigKeyEnum::AUTOMATED_REMINDER_SCHEDULED_MINUTE).and_return(minute)

				TriggerService.time_to_remind?(e, now, job_interval).should be_true
			end

			it "returns false when hour is right but minute should be processed by another job" do
				now = Time.new(2018,4,1,8,0,0, "-07:00")
				hour = 8
				minute = 15

				TriggerService.stub(:get_team_config_setting_for_event).with(e, TeamConfigKeyEnum::AUTOMATED_REMINDER_SCHEDULED_HOUR).and_return(hour)
				TriggerService.stub(:get_team_config_setting_for_event).with(e, TeamConfigKeyEnum::AUTOMATED_REMINDER_SCHEDULED_MINUTE).and_return(minute)

				TriggerService.time_to_remind?(e, now, job_interval).should be_false
			end

			it "returns false when minute is right but hour should be processed by another job" do
				now = Time.new(2018,4,1,9,0,0, "-07:00")
				hour = 8
				minute = 15
				job_interval = 15

				TriggerService.stub(:get_team_config_setting_for_event).with(e, TeamConfigKeyEnum::AUTOMATED_REMINDER_SCHEDULED_HOUR).and_return(hour)
				TriggerService.stub(:get_team_config_setting_for_event).with(e, TeamConfigKeyEnum::AUTOMATED_REMINDER_SCHEDULED_MINUTE).and_return(minute)

				TriggerService.time_to_remind?(e, now, job_interval).should be_false
			end

			it "only processed by one job" do
				first_time = Time.new(2018,4,1,8,0,0, "-07:00")
				second_time = Time.new(2018,4,1,8,15,0, "-07:00")
				hour = 8
				minute = 15

				TriggerService.stub(:get_team_config_setting_for_event).with(e, TeamConfigKeyEnum::AUTOMATED_REMINDER_SCHEDULED_HOUR).and_return(hour)
				TriggerService.stub(:get_team_config_setting_for_event).with(e, TeamConfigKeyEnum::AUTOMATED_REMINDER_SCHEDULED_MINUTE).and_return(minute)

				TriggerService.time_to_remind?(e, first_time, job_interval).should be_false
				TriggerService.time_to_remind?(e, second_time, job_interval).should be_true
			end
		end

		context "when settings are nil" do

			let(:e) { double(Event) }
			let(:job_interval) { 15 }

			it "returns false when hour is nil" do
				first_time = Time.new(2018,4,1,8,0,0, "-07:00")
				second_time = Time.new(2018,4,1,8,15,0, "-07:00")
				hour = nil
				minute = 15

				TriggerService.stub(:get_team_config_setting_for_event).with(e, TeamConfigKeyEnum::AUTOMATED_REMINDER_SCHEDULED_HOUR).and_return(hour)
				TriggerService.stub(:get_team_config_setting_for_event).with(e, TeamConfigKeyEnum::AUTOMATED_REMINDER_SCHEDULED_MINUTE).and_return(minute)

				TriggerService.time_to_remind?(e, first_time, job_interval).should be_false
			end

			it "returns false when minute is nil" do
				first_time = Time.new(2018,4,1,8,0,0, "-07:00")
				second_time = Time.new(2018,4,1,8,15,0, "-07:00")
				hour = 8
				minute = nil

				TriggerService.stub(:get_team_config_setting_for_event).with(e, TeamConfigKeyEnum::AUTOMATED_REMINDER_SCHEDULED_HOUR).and_return(hour)
				TriggerService.stub(:get_team_config_setting_for_event).with(e, TeamConfigKeyEnum::AUTOMATED_REMINDER_SCHEDULED_MINUTE).and_return(minute)

				TriggerService.time_to_remind?(e, first_time, job_interval).should be_false
			end
		end
	end


	describe "#reminders_sent_today?" do
		context "when settings have one value" do
			it "returns true when event is one day ahead" do
				now = Time.new(2018,4,1,8,0,0, "-07:00")
				reminder_settings = [1]
				days_ahead = 1
				minutes_ahead = 0

				e = double(Event)
				e.stub(:time_local).and_return(now + (days_ahead * 1.day) + (minutes_ahead * 1.minute))

				TriggerService.stub(:get_team_config_setting_for_event).with(e, TeamConfigKeyEnum::AUTOMATED_REMINDER_SETTINGS).and_return(reminder_settings)

				TriggerService.reminders_sent_today?(e, now).should be_true
			end

			it "returns true when event is seven days ahead" do
				now = Time.new(2018,4,1,8,0,0, "-07:00")
				reminder_settings = [7]
				days_ahead = 7
				minutes_ahead = 0

				e = double(Event)
				e.stub(:time_local).and_return(now + (days_ahead * 1.day) + (minutes_ahead * 1.minute))

				TriggerService.stub(:get_team_config_setting_for_event).with(e, TeamConfigKeyEnum::AUTOMATED_REMINDER_SETTINGS).and_return(reminder_settings)

				TriggerService.reminders_sent_today?(e, now).should be_true
			end

			it "returns false when event is seven days ahead" do
				now = Time.new(2018,4,1,8,0,0, "-07:00")
				reminder_settings = [1]
				days_ahead = 7
				minutes_ahead = 0

				e = double(Event)
				e.stub(:time_local).and_return(now + (days_ahead * 1.day) + (minutes_ahead * 1.minute))

				TriggerService.stub(:get_team_config_setting_for_event).with(e, TeamConfigKeyEnum::AUTOMATED_REMINDER_SETTINGS).and_return(reminder_settings)

				TriggerService.reminders_sent_today?(e, now).should be_false
			end		
		end

		context "when settings have two values" do
			it "returns true when event is one day ahead" do
				now = Time.new(2018,4,1,8,0,0, "-07:00")
				reminder_settings = [1,2]
				days_ahead = 1
				minutes_ahead = 0

				e = double(Event)
				e.stub(:time_local).and_return(now + (days_ahead * 1.day) + (minutes_ahead * 1.minute))

				TriggerService.stub(:get_team_config_setting_for_event).with(e, TeamConfigKeyEnum::AUTOMATED_REMINDER_SETTINGS).and_return(reminder_settings)

				TriggerService.reminders_sent_today?(e, now).should be_true
			end

			it "returns true when event is seven days ahead" do
				now = Time.new(2018,4,1,8,0,0, "-07:00")
				reminder_settings = [6,7]
				days_ahead = 7
				minutes_ahead = 0

				e = double(Event)
				e.stub(:time_local).and_return(now + (days_ahead * 1.day) + (minutes_ahead * 1.minute))

				TriggerService.stub(:get_team_config_setting_for_event).with(e, TeamConfigKeyEnum::AUTOMATED_REMINDER_SETTINGS).and_return(reminder_settings)

				TriggerService.reminders_sent_today?(e, now).should be_true
			end

			it "returns false when event is seven days ahead" do
				now = Time.new(2018,4,1,8,0,0, "-07:00")
				reminder_settings = [1,2]
				days_ahead = 7
				minutes_ahead = 0

				e = double(Event)
				e.stub(:time_local).and_return(now + (days_ahead * 1.day) + (minutes_ahead * 1.minute))

				TriggerService.stub(:get_team_config_setting_for_event).with(e, TeamConfigKeyEnum::AUTOMATED_REMINDER_SETTINGS).and_return(reminder_settings)

				TriggerService.reminders_sent_today?(e, now).should be_false
			end		
		end

		context "when settings have nil value" do
			it "returns false" do
				now = Time.new(2018,4,1,8,0,0, "-07:00")
				reminder_settings = nil
				days_ahead = 1
				minutes_ahead = 0

				e = double(Event)
				e.stub(:time_local).and_return(now + (days_ahead * 1.day) + (minutes_ahead * 1.minute))

				TriggerService.stub(:get_team_config_setting_for_event).with(e, TeamConfigKeyEnum::AUTOMATED_REMINDER_SETTINGS).and_return(reminder_settings)

				TriggerService.reminders_sent_today?(e, now).should be_false
			end	
		end
	end

end
