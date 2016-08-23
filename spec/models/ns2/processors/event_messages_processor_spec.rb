require 'spec_helper'
require 'sidekiq/testing'

describe Ns2::Processors::EventMessagesProcessor do
	let(:home_team){ FactoryGirl.create :team, :with_players, player_count: 1 }
	let(:away_team){ FactoryGirl.create :team, :with_players, player_count: 1 }
	let(:division) do
		division = FactoryGirl.create :division_season
		TeamDSService.add_team(division, home_team)
		TeamDSService.add_team(division, away_team)
		division
	end
	let(:user){ FactoryGirl.create :user }
	let(:junior){ FactoryGirl.create(:junior_user) }
	let(:follower){ FactoryGirl.create(:user) }

	before :each do
		@mail = double(deliver: "#yolo")
	end

	context 'division message' do
		describe '#created' do
			# sets ups a team with 1 org, 1 player, 1 junior player, 1 parent
			#  and one with 1 org, 1 player, 1 follower. 
			#  All except junior and follower should get one email.
			it 'sends some emails' do
				do_notify = double("UserTeamNotificationPolicy")
		    do_notify.stub(:should_notify?).and_return(true)
		    UserTeamNotificationPolicy.stub(:new).and_return(do_notify)
		        
				# note: My latest thoughts are that we don't need to check that we're
				#       passing in all the args, because as everything is fetch directly
				#       from the db using XXXX.find, it'll throw if shit is fucked. TS
				EventMessageMailer.should_receive(:organiser_division_message_created).twice.and_return(@mail)
				EventMessagePusher.should_not_receive(:organiser_division_message_created)
				EventMessageMailer.should_receive(:parent_division_message_created).and_return(@mail)
				EventMessageMailer.should_receive(:player_division_message_created).exactly(2).times.and_return(@mail)
				EventMessageMailer.should_not_receive(:follower_division_message_created)

				dm = division.messages.create!({
					text: "Hiya, dickhead!",
					user: user,
					sent_as_role_type: "League",
					sent_as_role_id: "1"
				})

				home_team.add_follower(follower)
				away_team.add_player(junior)
				away_team.add_parent(junior.parents.first)

				ae = AppEvent.create(obj: dm, subj: user, verb: "created", meta_data: {})
				Ns2::Processors::EventMessagesProcessor.process(ae)
				Ns2NotificationItemWorker.jobs.size.should eq(5)
				Ns2NotificationItemWorker.drain
			end
		end
	end
	context 'team message' do
		describe '#created' do
			it 'should send some emails, innit' do
				do_notify = double("UserTeamNotificationPolicy")
		    do_notify.stub(:should_notify?).and_return(true)
		    UserTeamNotificationPolicy.stub(:new).and_return(do_notify)

				EventMessageMailer.should_receive(:organiser_team_message_created).and_return(@mail)
				EventMessagePusher.should_not_receive(:organiser_team_message_created)
				EventMessageMailer.should_receive(:parent_team_message_created).and_return(@mail)
				EventMessageMailer.should_receive(:player_team_message_created).times.and_return(@mail)
				EventMessageMailer.should_not_receive(:follower_team_message_created)

				tm = home_team.messages.create!({
					text: "Hiya, dickhead!",
					user: user,
					meta_data: { recipients: { groups: ['1', '2'] } },
					sent_as_role_type: "Team",
					sent_as_role_id: "1"
				})

				home_team.add_follower(follower)
				home_team.add_player(junior)
				home_team.add_parent(junior.parents.first)
				tm.stub(recipient_users: [home_team.organisers.first, home_team.players.second, follower, junior, junior.parents.first])

				ae = AppEvent.create(obj: tm, subj: user, verb: "created", meta_data: {})
				AppEvent.stub(find: ae)
				Ns2::Processors::EventMessagesProcessor.process(ae)
				Ns2NotificationItemWorker.jobs.size.should eq(3)
				Ns2NotificationItemWorker.drain
			end
			it 'should not send any emails' do
		    do_not_notify = double("UserTeamNotificationPolicy")
		    do_not_notify.stub(:should_notify?).and_return(false)
		    UserTeamNotificationPolicy.stub(:new).and_return(do_not_notify)

				EventMessageMailer.should_not_receive(:organiser_team_message_created)
				EventMessagePusher.should_not_receive(:organiser_team_message_created)
				EventMessageMailer.should_not_receive(:parent_team_message_created)
				EventMessageMailer.should_not_receive(:player_team_message_created)
				EventMessageMailer.should_not_receive(:follower_team_message_created)

				tm = home_team.messages.create!({
					text: "Hiya, dickhead!",
					user: user,
					meta_data: { recipients: { groups: ['1', '2'] } },
					sent_as_role_type: "Team",
					sent_as_role_id: "1"
				})

				home_team.add_follower(follower)
				home_team.add_player(junior)
				home_team.add_parent(junior.parents.first)
				tm.stub(recipient_users: [home_team.organisers.first, home_team.players.second, follower, junior, junior.parents.first])

				ae = AppEvent.create(obj: tm, subj: user, verb: "created", meta_data: {})
				AppEvent.stub(find: ae)
				Ns2::Processors::EventMessagesProcessor.process(ae)
				Ns2NotificationItemWorker.jobs.size.should eq(0)
				Ns2NotificationItemWorker.drain
			end
		end
	end
	context 'event message' do
		describe '#created' do
			it 'electronic mail communications are generated and sent' do
				do_notify = double("UserTeamNotificationPolicy")
		    do_notify.stub(:should_notify?).and_return(true)
		    UserTeamNotificationPolicy.stub(:new).and_return(do_notify)

				EventMessageMailer.should_receive(:organiser_event_message_created).and_return(@mail)
				EventMessagePusher.should_not_receive(:organiser_event_message_created)
				EventMessageMailer.should_receive(:parent_event_message_created).and_return(@mail)
				EventMessageMailer.should_receive(:player_event_message_created).and_return(@mail)
				EventMessageMailer.should_not_receive(:follower_event_message_created)

				event = FactoryGirl.create :event, team: home_team
				home_team.add_follower(follower)
				home_team.add_player(junior)
				home_team.add_parent(junior.parents.first)

				em = event.messages.create!({
					text: "Hiya, dickhead!",
					user: user,
					sent_as_role_type: "League",
					sent_as_role_id: "1"
				})
				em.stub(recipient_users: [home_team.organisers.first, home_team.players.second, follower, junior, junior.parents.first])

				ae = AppEvent.create(obj: em, subj: user, verb: "created", meta_data: {})
				AppEvent.stub(find: ae)
				Ns2::Processors::EventMessagesProcessor.process(ae)
				Ns2NotificationItemWorker.jobs.size.should eq(3)
				Ns2NotificationItemWorker.drain
			end
		end
	end
end