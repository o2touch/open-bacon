require 'spec_helper'
require 'sidekiq/testing'

describe Ns2::Processors::ScheduledNotificationsProcessor do

	context "#weekly_event_schedule" do
		before :each do

			robot = User.find(1)
			meta_data = { time_zone: "Europe/Berlin", utc_run_time: Time.now }
			@ae = AppEvent.create!(obj: robot, subj: robot, verb: "weekly_event_schedule", meta_data: meta_data)
			@team = FactoryGirl.create :team
			@team2 = FactoryGirl.create :team
			@fake_mail = double(deliver: "brap")
			@fake_push = double(deliver: [{}, { "ok" => true }])

			@user_one = FactoryGirl.create(:user, :with_mobile_device, time_zone: "Europe/Madrid")
			@user_two = FactoryGirl.create(:user, :with_mobile_device, time_zone: "Europe/Paris")
			@user_three = FactoryGirl.create(:user, :with_mobile_device, time_zone: "Europe/Berlin")
			@team.add_player(@user_one)
			@team.add_player(@user_two)
			@team.add_player(@user_three)
			@team2.add_player(@user_one)
			@team2.add_player(@user_two)
			@team2.add_player(@user_three)

		# Always notify for @team
			do_notify = double("UserTeamNotificationPolicy")
      do_notify.stub(:should_notify?).and_return(true)
      UserTeamNotificationPolicy.stub(:new).with(anything(), @team).and_return(do_notify)

      # Never notify for @team2
			do_not_notify = double("UserTeamNotificationPolicy")
      do_not_notify.stub(:should_notify?).and_return(false)
      UserTeamNotificationPolicy.stub(:new).with(anything(), @team2).and_return(do_not_notify)

			@event = FactoryGirl.create(:event, time: 1.day.from_now)
			@event2 = FactoryGirl.create(:event, time: 1.day.from_now)
			TeamEventsService.add(@team, @event, false, false)
			TeamEventsService.add(@team2, @event2, false, false)
		end

		it 'sends notifications for users in the correct TZ' do
			ScheduledNotificationMailer.should_receive(:user_weekly_event_schedule).once.and_return(@fake_mail)
			
			# Removed Push Notifications
			# ScheduledNotificationPusher.should_receive(:user_weekly_event_schedule).once.and_return(@fake_push)
			ScheduledNotificationPusher.should_not_receive(:user_weekly_event_schedule)

			Ns2::Processors::ScheduledNotificationsProcessor.process(@ae)
			Ns2NotificationItemWorker.jobs.size.should eq(1)
			Ns2NotificationItemWorker.drain
		end

		it 'sends no notifications if no events in the next 9 days' do
			@event.update_attribute(:time, 10.days.from_now)
			@event2.update_attribute(:time, 10.days.from_now)

			ScheduledNotificationMailer.should_not_receive(:user_weekly_event_schedule)
			ScheduledNotificationPusher.should_not_receive(:user_weekly_event_schedule)

			Ns2::Processors::ScheduledNotificationsProcessor.process(@ae)
			Ns2NotificationItemWorker.jobs.size.should eq(0)
			Ns2NotificationItemWorker.drain
		end

		it 'sends only emails if events are 7 days+' do
			@event.update_attribute(:time, 8.days.from_now)

			ScheduledNotificationMailer.should_receive(:user_weekly_event_schedule).once.and_return(@fake_mail)
			ScheduledNotificationPusher.should_not_receive(:user_weekly_event_schedule)

			Ns2::Processors::ScheduledNotificationsProcessor.process(@ae)
			Ns2NotificationItemWorker.jobs.size.should eq(1)
			Ns2NotificationItemWorker.drain
		end

		it 'sends notifications to parents if user is a junior' do
			@user_five = FactoryGirl.create :user, :with_mobile_device
			@user_four = FactoryGirl.create :junior_user, parent: @user_five, time_zone: "Europe/Talin"
			@team.profile.update_attributes(age_group: AgeGroupEnum::UNDER_10) #make this a junior team      
			TeamUsersService.add_player(@team, @user_four, false, nil, false) 
			@ae.meta_data[:time_zone] = "Europe/Talin"
			@ae.save!

			ScheduledNotificationMailer.should_receive(:parent_weekly_event_schedule).once.and_return(@fake_mail)
			
			# Removed Push Notifcations
			# ScheduledNotificationPusher.should_receive(:parent_weekly_event_schedule).once.and_return(@fake_push)
			ScheduledNotificationPusher.should_not_receive(:user_weekly_event_schedule)

			Ns2::Processors::ScheduledNotificationsProcessor.process(@ae)
			Ns2NotificationItemWorker.jobs.size.should eq(1)
			Ns2NotificationItemWorker.drain
		end

		it 'sends only emails if a user is in 2+ teams' do
			@team_two = FactoryGirl.create :team
			@team_two.add_player @user_three

			ScheduledNotificationMailer.should_receive(:user_weekly_event_schedule).once.and_return(@fake_mail)
			ScheduledNotificationPusher.should_not_receive(:user_weekly_event_schedule)

			Ns2::Processors::ScheduledNotificationsProcessor.process(@ae)
			Ns2NotificationItemWorker.jobs.size.should eq(1)
			Ns2NotificationItemWorker.drain
		end

		it 'works for followers' do
			TeamUsersService.remove_player_from_team(@team, @user_three)
			@team.add_follower(@user_three)

			ScheduledNotificationMailer.should_receive(:user_weekly_event_schedule).once.and_return(@fake_mail)
			
			# Removed Push Notifications
			# ScheduledNotificationPusher.should_receive(:user_weekly_event_schedule).once.and_return(@fake_push)
			ScheduledNotificationPusher.should_not_receive(:user_weekly_event_schedule)

			Ns2::Processors::ScheduledNotificationsProcessor.process(@ae)
			Ns2NotificationItemWorker.jobs.size.should eq(1)
			Ns2NotificationItemWorker.drain
		end
	end

	context "#weekly_next_game" do
		before :each do
			
			do_not_notify = double("UserTeamNotificationPolicy")
	    do_not_notify.stub(:should_notify?).and_return(true)

	    UserTeamNotificationPolicy.stub(:new).and_return(do_not_notify)

			@team = FactoryGirl.create :team
			@user_one = FactoryGirl.create(:user, :with_mobile_device, time_zone: "Europe/Madrid")
			@user_two = FactoryGirl.create(:user, :email => nil, :mobile_number => "+123456789", time_zone: "Europe/Madrid")
			@team.add_player(@user_one)
			@team.add_player(@user_two)

			@event = FactoryGirl.create(:event, time: 1.day.from_now)
			TeamEventsService.add(@team, @event, false, false)
			
			@fake_smser = double(deliver: {status: "success" })
			@fake_push = double(deliver: [{}, { :ok => true }])
		end

		context "when push preferable" do
			before :each do
				meta_data = {}
				@ae = AppEvent.create!(obj: @event, subj: @user_one, verb: "weekly_next_game", meta_data: meta_data)
			end
			it 'sends notifications for user' do
				ScheduledNotificationPusher.should_receive(:member_weekly_next_game).once.and_return(@fake_push)
				ScheduledNotificationSmser.should_not_receive(:member_weekly_next_game)

				Ns2::Processors::ScheduledNotificationsProcessor.process(@ae)
				Ns2NotificationItemWorker.jobs.size.should eq(1)
				Ns2NotificationItemWorker.drain
			end
		end

		context "when sms preferable", sidekiq: :inline do

			before :each do
				meta_data = {}
				@ae = AppEvent.create!(obj: @event, subj: @user_two, verb: "weekly_next_game", meta_data: meta_data)
			end

			it 'sends notifications for user' do
				ScheduledNotificationSmser.should_receive(:member_weekly_next_game).once.and_return(@fake_smser)
				ScheduledNotificationPusher.should_not_receive(:member_weekly_next_game)

				Ns2::Processors::ScheduledNotificationsProcessor.process(@ae)
			end
		end

		context "when should not notify" do
			before :each do
				do_not_notify = double("UserTeamNotificationPolicy")
		        do_not_notify.stub(:should_notify?).and_return(false)

		        UserTeamNotificationPolicy.stub(:new).and_return(do_not_notify)

				meta_data = {}
				@ae = AppEvent.create!(obj: @event, subj: @user_two, verb: "weekly_next_game", meta_data: meta_data)
			end

			it 'does not send notifications for user' do
				ScheduledNotificationSmser.should_not_receive(:member_weekly_next_game)
				ScheduledNotificationPusher.should_not_receive(:member_weekly_next_game)

				Ns2::Processors::ScheduledNotificationsProcessor.process(@ae)
			end		
		end
	end
end