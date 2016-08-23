require 'spec_helper'
require 'sidekiq/testing'

describe EventNotificationService do
	#Sidekiq::Testing.disable!
	let(:team){ FactoryGirl.create(:team, :with_events, :with_players, event_count: 2, player_count: 3) }
	let(:player){ team.players.first }
	let(:event){ FactoryGirl.create(:event, :with_players, player_count: 2, user: team.created_by, team: team) }
	let(:tse){ event.teamsheet_entries.first }
	let(:team_invite){ TeamInvite.get_invite(team, FactoryGirl.create(:user)) }

	let(:junior_team){ FactoryGirl.create(:junior_team, :with_events, :with_players, event_count: 2, player_count: 3) }
	let(:junior_player){ junior_team.players.first }
	let(:junior_event){ junior_team.events.first }
	let(:junior_tse){ junior_event.teamsheet_entries.second }
	
	let(:junior_team){ FactoryGirl.create(:junior_team, :with_events, :with_players, event_count: 2, player_count: 3) }

	# describe 'send_schedules' do
	# 	it 'updates schedule_last_sent on the team' do
	# 		lambda{ EventNotificationService.send_schedule_updates(team, team.organisers.first) }.should change(team, :schedule_last_sent)
	# 	end

	# 	context 'a schedule has never been sent' do
	# 		it 'includes all future events'
	# 	end

	# 	context 'a shedule has been sent' do
	# 		it 'includes all events created since schedule last sent'
	# 		it 'includes all events updated since schedule last sent'
	# 	end
	# end


	# NO LONGER USED TS
	# describe 'send_invitations' do
	# 	it 'sends out invitations' do
	# 		EventNotificationService.send_invitations(event)
	# 		last_delayed_emails.count.should eq(event.users.count)
	# 	end
	# end

	# describe 'send_invitation' do
	# 	context 'bad things happened' do 
	# 		it 'returns false if tse is nil' do
	# 			EventNotificationService.send_invitation(nil).should eq(false)
	# 		end

	# 		it 'returns false if tse.invite_sent == true' do
	# 			tse.invite_sent = true
	# 			EventNotificationService.send_invitation(tse).should eq(false)
	# 		end
	# 	end

	# 	context 'good things happened' do
	# 		it 'sends out an email' do
	# 			EventNotificationService.send_invitation(tse)
	# 			emails = last_delayed_emails
	# 			emails.count.should eq(1)
	# 		end

	# 		it 'sets invite_sent to true' do
	# 			EventNotificationService.send_invitation(tse)
	# 			tse.reload
	# 			tse.invite_sent.should eq(true)
	# 		end
	# 	end
	# end

	# describe 'send_updates' do
	# 	it 'sends emails to all players excluding the person who performed the action' do
	# 		team_event = tse.event
	# 		team = team_event.team
	# 		action_performer = team.organisers.first

	# 		EventNotificationService.send_updates(team_event, {:title => 'title'}, action_performer)
	# 		delivered_emails = last_delayed_emails

	# 		expected_deliveries = team.members.map(&:email)
	# 		expected_deliveries.delete(action_performer.email)
			
	# 		delivered_emails.map(&:to).flatten.should eql expected_deliveries
	# 	end 

	# 	it 'sends no emails if no updates were made' do
	# 		team_event = tse.event
	# 		team = team_event.team
	# 		action_performer = team.organisers.first

	# 		EventNotificationService.send_updates(team_event, {}, action_performer)
	# 		last_delayed_emails.count.should == 0
	# 	end
	# end

	# describe 'send_update' do
	# 	it 'sends one email' do
	# 		event = tse.event
	# 		user = tse.user
	# 		EventNotificationService.send_update(user, event, {:title => 'title'})
	# 		delivered_emails = last_delayed_emails		
	# 		delivered_emails.count.should == 1
	# 		delivered_emails.map(&:to).flatten.should eql [user.email]
	# 	end

	# 	context 'the player is a junior' do
	# 		it 'sends the email to the parent' do
	# 			event = junior_tse.event
	# 			user = junior_tse.user
	# 			parent = junior_tse.user.parents.first

	# 			EventNotificationService.send_update(user, event, {:title => 'title'})
				
	# 			delivered_emails = last_delayed_emails		
	# 			delivered_emails.count.should == 1
	# 			delivered_emails.map(&:to).flatten.should eql [parent.email]
	# 		end
	# 	end
	# end

	# describe 'send_cancellations' do
	# 	it 'sends emails to all team members' do
	# 		EventNotificationService.send_cancellations(event)
	# 		last_delayed_emails.count.should eq(event.team.members.count)
	# 	end
	# end

	# describe 'send_cancellation' do
	# 	it 'sends one email' do
	# 		EventNotificationService.send_cancellation(tse.user, tse.event)
	# 		last_delayed_emails.count.should eq(1)
	# 	end

	# 	context 'the player is a junior' do
	# 		it 'sends the email to the parent' do
	# 			parent = junior_tse.user.parents.first
	# 			EventNotificationService.send_cancellation(junior_tse.user, junior_tse.event)
	# 			last_delayed_email.should deliver_to("#{parent.name} <#{parent.email}>")
	# 		end
	# 	end
	# end

	# describe 'send_activations' do
	# 	it 'sends emails to all team members' do
	# 		EventNotificationService.send_activations(event)
	# 		last_delayed_emails.count.should eq(event.team.members.count)
	# 	end
	# end

	# describe 'send_activation' do
	# 	it 'sends one email' do
	# 		EventNotificationService.send_activation(tse.user, tse.event)
	# 		last_delayed_emails.count.should eq(1)
	# 	end

	# 	context 'the player is a junior' do
	# 		it 'sends the email to the parent' do
	# 			parent = junior_tse.user.parents.first
	# 			EventNotificationService.send_activation(junior_tse.user, junior_tse.event)
	# 			last_delayed_email.should deliver_to("#{parent.name} <#{parent.email}>")
	# 		end
	# 	end
	# end



	# 			EventNotificationService.send_invitation_reminders(event)
	# 			last_delayed_emails.count.should eq(event.users.count - 2)
	# 		end
	# 	end
	# end


	# SR - I DONT THIS WE USE THIS ANYMORE
	# describe 'send_reminders' do
	# 	it 'sends emails to all players' do
	# 		EventNotificationService.send_reminders(event)
	# 		#last_delayed_emails.count.should eq(event.users.count) # No time to shine
	# 	end
	# end

	# describe 'send_reminder' do
	# 	it 'sends one email' do
	# 		EventNotificationService.send_reminder(tse)
	# 		last_delayed_emails.count.should eq(1)
	# 	end

	# 	context 'the player is a junior' do
	# 		it 'sends the email to the parent' do
	# 			parent = junior_tse.user.parents.first
	# 			EventNotificationService.send_reminder(junior_tse)
	# 			last_delayed_email.should deliver_to("#{parent.name} <#{parent.email}>")
	# 		end
	# 	end
	# end

	describe '#scheduled_event_reminder_triggered' do
		context "with adult user" do
			context "one event" do
				it 'sends the single event reminder template' do

					user = FactoryGirl.create(:user)
					event = FactoryGirl.create(:event)

					EventInvitesService.add_players(event, [user], false)

					# event.stub(:teamsheet_entries).and_return(user)
					UserMailer.stub(:delay).and_return(UserMailer)

					events = [event.id]

					UserMailer.should_receive(:scheduled_event_reminder_single).once
					EventNotificationService.scheduled_event_reminder_triggered(user.id, events)
				end
			end
			context "multiple events" do
				it 'sends the multiple event reminder template' do
					
					user = FactoryGirl.create(:user)
					event1 = FactoryGirl.create(:event)
					event2 = FactoryGirl.create(:event)

					events = [event1, event2]

					EventInvitesService.add_players(event1, [user], false)
					EventInvitesService.add_players(event2, [user], false)

					UserMailer.stub(:delay).and_return(UserMailer)
					UserMailer.should_receive(:scheduled_event_reminder_multiple).once

					EventNotificationService.scheduled_event_reminder_triggered(user.id, events)
				end
			end
		end

		context "with junior player" do
			it 'does not email junior user directly', :sidekiq => false do
					user = FactoryGirl.create(:junior_user)
					event = FactoryGirl.create(:event)

					EventInvitesService.add_players(event, [user], false)

					events = [event.id]

					teamsheet_entry = event.teamsheet_entry_for_user(user)

					JuniorMailerService.should_not_receive(:scheduled_event_reminder_single)
					EventNotificationService.scheduled_event_reminder_triggered(user.id, events)
			end

			it 'does not email users who should not be emailed', :sidekiq => false do
					user = FactoryGirl.create(:user)
					user.stub(:should_send_email?).and_return(false)
					
					event = FactoryGirl.create(:event)

					EventInvitesService.add_players(event, [user], false)

					events = [event.id]

					teamsheet_entry = event.teamsheet_entry_for_user(user)

					JuniorMailerService.should_not_receive(:scheduled_event_reminder_single)
					EventNotificationService.scheduled_event_reminder_triggered(user.id, events)
			end
		end
	end

	def push_message_to_feed(message)
		emo = EventMessageHelper.new
		emo.create_activity_item(message)
		emo.push_create_to_feeds(message)
	end

	# describe 'new event message is created' do 
	# 	it 'sends email to the rest of the teamsheet' do
	# 		last_delayed_emails.count.should eq(0)

	# 		message = team.events.first.messages.create!(text: "TIM IS AMAZING", user: player, meta_data: { 'recipients' => {} })
	# 		push_message_to_feed(message)

	# 		last_delayed_emails.count.should == team.events.first.invitees.count - 1
	# 	end

	# 	it 'sends email to the specified users and the teamsheet if no groups specified' do
	# 		last_delayed_emails.count.should eq(0)

	# 		team_member = team.members.first
	# 		meta_data = {
	# 			'recipients' => {
	# 				'users' => [team_member.id, team.members.second.id],
	# 				'groups' => []
	# 			}
	# 		}

	# 		message = team.events.first.messages.create!(text: "TIM IS AMAZING", user: team_member, meta_data: meta_data)
	# 		push_message_to_feed(message)

	# 		last_delayed_emails.count.should == team.events.first.invitees.count - 1
	# 	end

	# 	it 'sends email to the specified users and the groups' do
	# 		last_delayed_emails.count.should eq(0)

	# 		team_member = team.members.first
	# 		meta_data = {
	# 			'recipients' => {
	# 				'users' => [team_member.id, team.members.second.id],
	# 				'groups' => [MessageGroups::UNAVAILABLE]
	# 			}
	# 		}

	# 		event = team.events.first

	# 		unavailable_player_ids = event.unavailable_players.map(&:id)
	# 		expected_email_count = (unavailable_player_ids | meta_data['recipients']['users'] | [team_member.id]).uniq.count

	# 		message = event.messages.create!(text: "TIM IS AMAZING", user: team_member, meta_data: meta_data)
	# 		push_message_to_feed(message)

	# 		last_delayed_emails.count.should == expected_email_count - 1 #minus one sine dont send to user woho posted message
	# 	end

	# 	context 'the team is a junior team' do
	# 		it 'sends the emails to the parents'
	# 	end
	# end

	# describe 'new team message is created' do 
	# 	it 'sends email to the rest of the team' do
	# 		last_delayed_emails.count.should eq(0)

	# 		message = team.messages.create!(text: "TIM IS AMAZING", user: player, meta_data: { 'recipients' => {} })
	# 		push_message_to_feed(message)

	# 		last_delayed_emails.count.should == team.members.count - 1
	# 	end

	# 	it 'sends email to the rest of the team even if specific users specified' do
	# 		last_delayed_emails.count.should eq(0)

	# 		meta_data = {
	# 			'recipients' => {
	# 				'users' => [team.members.first.id, team.members.second.id],
	# 				'groups' => []
	# 			}
	# 		}

	# 		message = team.messages.create!(text: "TIM IS AMAZING", user: player, meta_data: meta_data)
	# 		push_message_to_feed(message)

	# 		last_delayed_emails.count.should == team.members.count - 1
	# 	end

	# 	context 'the team is a junior team' do
	# 		it 'sends the emails to the parents'
	# 	end
	# end

	# describe 'new league team message is created' do
	# 	before :each do
	# 		@league = FactoryGirl.create(:league)
 #      @organiser = @league.organisers.first      
 #      @division = FactoryGirl.create(:division, :league => @league)
 #      @division.teams << team
	# 	end 
		
	# 	it 'sends emails to the team' do
	# 		last_delayed_emails.count.should eq(0)

	# 		message = @division.messages.create!(text: "TIM IS AMAZING", user: @organiser, meta_data: { 'recipients' => {} })
	# 		push_message_to_feed(message)

	# 		last_delayed_emails.count.should == (team.members.count) * (@division.teams.count)
	# 	end

	# 	it 'sends email to the team and IGNORES specific users specified' do
	# 		last_delayed_emails.count.should eq(0)

	# 		meta_data = {
	# 			'recipients' => {
	# 				'users' => [team.members.first.id, team.members.second.id],
	# 				'groups' => []
	# 			}
	# 		}

	# 		message = @division.messages.create!(text: "TIM IS AMAZING", user: @organiser, meta_data: { 'recipients' => {} })
	# 		push_message_to_feed(message)

	# 		last_delayed_emails.count.should == (team.members.count) * (@division.teams.count)
	# 	end

	# 	context 'the team is a junior team' do
	# 		it 'sends the emails to the parents'
	# 	end
	# end
end