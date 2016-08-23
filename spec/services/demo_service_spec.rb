require 'spec_helper'
require 'rake'

describe DemoService do
	let(:user){ FactoryGirl.create(:user, :with_teams, :with_events, team_count: 1, event_count: 1) }
	let(:team) do
		team = user.teams_as_organiser.first
		team.demo_mode = 1
		team.save
		team
	end

	# this is WAY too much. We shouldn't care how it does that shit.
	# but equally other tests (ie. lack thereof) rely on this working, so it should be tested.
	# not sure what the answer is here. TS
	describe 'respond' do
		before :each do
			@response = InviteResponseEnum::AVAILABLE
			@tse = double("tse")
			TeamsheetEntriesService.should_receive(:set_availability).with(@tse, @response)
			@tse.should_receive(:send_push_notification).with("update")
			TeamsheetEntry.stub(find: @tse)
		end
		it 'creates the invite response and sends the notificaitons' do
			DemoService.respond(1, @response)
		end
	end

	# as above, except to the extent that everything I've written is fucking pointless TS
	describe 'message' do
		before :each do
			@messages = double("create")
			@messages.should_receive(:create)
			@event = double("event", messages: @messages)
			@tse = double("tse", event: @event)
			@user = double("user")
			@tse.stub(user: @user)
			@text = "hi"
			TeamsheetEntry.stub(find: @tse)
		end
		it 'calls the right shit' do
			DemoService.message(1, @text)
		end
	end

	describe 'add_demo_users' do
		context 'invalid method call' do
			it 'returns false if the team is null' do
				DemoService.add_demo_users(nil)
			end
		end
		context 'valid method call' do
			before :each do
			end
			it 'adds all demo users to the team and makes events demo events' do
				TeamsheetEntry.should_receive(:create).exactly(DemoUser.all.count).times
				DemoService.add_demo_users(team).should eq(true)
				team.reload
				team.events.each do |event|
					event.type.should eq("DemoEvent")
				end
			end
		end
	end

	describe 'generate_responses' do
		context 'invalid method call' do
			it 'returns false if the event is null' do
				DemoService.generate_responses(nil).should eq(false)
			end
			it 'returns false if it is not a demo event' do
				DemoService.generate_responses(Event.new).should eq(false)
			end
		end
		# everything else is random, so can't really test easily...
		context 'valid method call' do

			it 'sets responses for all demo players' do
				tses = []
				(1..4).each do
					tses << FactoryGirl.build_stubbed(:teamsheet_entry, user: FactoryGirl.build_stubbed(:demo_user))
				end
				@event = double("event")
				@event.stub(type: "DemoEvent")
				@event.stub(teamsheet_entries: tses)
				DemoService.stub(message: "give a shit")

				DemoService.should_receive(:respond).exactly(tses.count).times
				DemoService.generate_responses(@event)
				Sidekiq::Worker.drain_all
			end
			it 'does not change pepes response' do
				tses = [FactoryGirl.build_stubbed(:teamsheet_entry, user: FactoryGirl.build_stubbed(:demo_user, username: "pepe"))]
				@event = double("event")
				@event.stub(type: "DemoEvent")
				@event.stub(teamsheet_entries: tses)
				DemoService.stub(message: "give a shit")

				DemoService.should_not_receive(:respond)
				DemoService.generate_responses(@event)
			end
		end
	end
end