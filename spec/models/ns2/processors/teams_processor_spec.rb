require 'spec_helper'
require 'sidekiq/testing'

describe Ns2::Processors::TeamsProcessor do
	let(:team){ FactoryGirl.create :team, :with_players, :with_events, event_count: 2, player_count: 3 }
	let(:junior_team){ FactoryGirl.create :junior_team, :with_players, :with_events, event_count: 2, player_count: 3 }
	let(:user){ FactoryGirl.create(:user, :with_mobile_device) }
	let(:follower){ FactoryGirl.create(:user) }

	before :each do
		@mail = double(deliver: "hiiii")
		@pudh = double(deliver: [{},{"ok" => true}])
		User.any_instance.stub(pushable_mobile_devices: ["hi"])
		User.any_instance.stub(should_send_push_notifications?: true)
	end

	describe '#schedule_created' do
		it 'sends some nice emails' do
			do_notify = double("UserTeamNotificationPolicy")
      do_notify.stub(:should_notify?).and_return(true)
      UserTeamNotificationPolicy.stub(:new).and_return(do_notify)

			TeamPusher.should_receive(:player_schedule_created).exactly(4).times.and_return(@push)
			TeamMailer.should_receive(:player_schedule_created).exactly(4).times do |recipient_id, tenant_id, data|
				u = User.find(recipient_id)
				t = Team.find(data[:team_id])
				u.teams.should include(t)
				data[:event_ids].should eq(t.events.map{|e| e.id})
			end.and_return(@mail)

			TeamPusher.should_receive(:follower_schedule_created).exactly(1).times.and_return(@push)
			TeamMailer.should_receive(:follower_schedule_created).exactly(1).times do |recipient_id, tenant_id, data|
				u = User.find(recipient_id)
				t = Team.find(data[:team_id])
				t.has_follower?(u).should be_true
				data[:event_ids].should eq(t.events.map{|e| e.id})
			end.and_return(@mail)

			team.add_follower(follower)
			ae = AppEvent.create!(obj: team, subj: user, verb: "schedule_created", meta_data: {})
			Ns2::Processors::TeamsProcessor.process(ae)
			Ns2NotificationItemWorker.jobs.size.should eq(10)
			Ns2NotificationItemWorker.drain
		end

		it 'sends some nice emails' do
			do_not_notify = double("UserTeamNotificationPolicy")
	        do_not_notify.stub(:should_notify?).and_return(false)
	        UserTeamNotificationPolicy.stub(:new).and_return(do_not_notify)

			TeamPusher.should_not_receive(:player_schedule_created)
			TeamMailer.should_not_receive(:player_schedule_created)

			TeamPusher.should_not_receive(:follower_schedule_created)
			TeamMailer.should_not_receive(:follower_schedule_created)

			team.add_follower(follower)
			ae = AppEvent.create!(obj: team, subj: user, verb: "schedule_created", meta_data: {})
			Ns2::Processors::TeamsProcessor.process(ae)
			Ns2NotificationItemWorker.jobs.size.should eq(0)
			Ns2NotificationItemWorker.drain
		end

		# the above, and below code combined 100% cover a junior test here, so I ain't doing it
		# and you can go fuck your self if you're going to get eggy about that...
	end

	describe '#schedule_updated' do
		it 'sends some nice emails' do
			do_notify = double("UserTeamNotificationPolicy")
		    do_notify.stub(:should_notify?).and_return(true)
		    UserTeamNotificationPolicy.stub(:new).and_return(do_notify)

			TeamPusher.should_receive(:player_schedule_updated).exactly(4).times.and_return(@push)
			TeamMailer.should_receive(:player_schedule_updated).exactly(4).times do |recipient_id, tenant_id, data|
				u = User.find(recipient_id)
				t = Team.find(data[:team_id])
				u.teams.should include(t)
				data[:event_ids].should eq(t.events.map{|e| e.id})
			end.and_return(@mail)

			TeamPusher.should_receive(:follower_schedule_updated).exactly(1).times.and_return(@push)
			TeamMailer.should_receive(:follower_schedule_updated).exactly(1).times do |recipient_id, tenant_id, data|
				u = User.find(recipient_id)
				t = Team.find(data[:team_id])
				t.has_follower?(u).should be_true
				data[:event_ids].should eq(t.events.map{|e| e.id})
			end.and_return(@mail)

			team.add_follower(follower)
			ae = AppEvent.create!(obj: team, subj: user, verb: "schedule_updated", meta_data: {})
			Ns2::Processors::TeamsProcessor.process(ae)
			Ns2NotificationItemWorker.jobs.size.should eq(10)
			Ns2NotificationItemWorker.drain
		end

		it 'sends some nice emails to parents' do
			do_notify = double("UserTeamNotificationPolicy")
		    do_notify.stub(:should_notify?).and_return(true)
		    UserTeamNotificationPolicy.stub(:new).and_return(do_notify)

			TeamPusher.should_receive(:player_schedule_updated).exactly(1).times.and_return(@push)
			TeamPusher.should_receive(:parent_schedule_updated).exactly(3).times.and_return(@push)
			TeamMailer.should_receive(:player_schedule_updated).once.and_return(@mail)
			TeamMailer.should_receive(:parent_schedule_updated).exactly(3).times do |recipient_id, tenant_id, data|
				u = User.find(recipient_id)
				t = Team.find(data[:team_id])
				u.teams_as_parent.should include(t)
				u.children.first.teams.should include(t)
				data[:event_ids].should eq(t.events.map{|e| e.id})
			end.and_return(@mail)

			TeamPusher.should_receive(:follower_schedule_updated).exactly(1).times.and_return(@push)
			TeamMailer.should_receive(:follower_schedule_updated).exactly(1).times do |recipient_id, tenant_id, data|
				u = User.find(recipient_id)
				t = Team.find(data[:team_id])
				t.has_follower?(u).should be_true
				data[:event_ids].should eq(t.events.map{|e| e.id})
			end.and_return(@mail)

			junior_team.add_follower(follower)
			ae = AppEvent.create!(obj: junior_team, subj: user, verb: "schedule_updated", meta_data: {})
			Ns2::Processors::TeamsProcessor.process(ae)
			Ns2NotificationItemWorker.jobs.size.should eq(10)
			Ns2NotificationItemWorker.drain
		end
	end
end