require 'spec_helper'

describe Api::V1::EventMessagesController do
	render_views
	
	context 'event message' do
		before :each do
			@user = FactoryGirl.create :user, :with_teams, :team_count => 1
	    request.env['X-AUTH-TOKEN'] = @user.authentication_token
	    @event = FactoryGirl.create :event, user: @user, team: @user.teams_as_organiser.first
		end

		describe '#create', type: :api do
			def do_create	
				message_attrs = { text: "text", event_id: @event.id }
				post :create, format: :json, message: message_attrs
			end

			it 'returns 422 if request is missing messagable id' do
				message_attrs = { text: "text" }
				post :create, format: :json, message: message_attrs
				response.status.should eq 422
			end

			it 'returns 422 if request is for an invalid messagable type' do
				message_attrs = { text: "text", user_id: @user.id }
				post :create, format: :json, message: message_attrs
				response.status.should eq 422
			end

			it 'returns 422 if request if messageable lookup fails' do
				message_attrs = { text: "text", event_id: 100 }
				post :create, format: :json, message: message_attrs
				response.status.should eq 422
			end

			context 'senders perspetive' do
				before :each do
					@organiser = FactoryGirl.create :user, :with_teams, :team_count => 1
			    @team = @organiser.teams_as_organiser.first
			    @event = FactoryGirl.create :event, user: @organiser, team: @team
			   	request.env['X-AUTH-TOKEN'] = @organiser.authentication_token

				end

				it 'does not raise an error for a players perspetive request' do
					#TODO Move this out.
					organiser = FactoryGirl.create :user, :with_teams, :team_count => 1
			    local_user = FactoryGirl.create :user
			    team = organiser.teams_as_organiser.first
			    team.add_player(local_user)
			    local_user.team_roles.reload
			    event = FactoryGirl.create :event, user: organiser, team: team
			    tse = FactoryGirl.create :teamsheet_entry, user: local_user, event: event
      		event.teamsheet_entries << tse
			   	request.env['X-AUTH-TOKEN'] = local_user.authentication_token
					message_attrs = { text: "text", event_id: event.id }
					post :create, format: :json, message: message_attrs

					response.status.should == 200
				end

				it 'does not raise an error for an organisers perspetive request' do
					message_attrs = { text: "text", team_id: @team.id }
					post :create, format: :json, message: message_attrs

					response.status.should == 200
				end

				it 'raises error if the user does not hold the role to a post message' do
					organiser = FactoryGirl.create :user, :with_teams, :team_count => 1
			    local_user = FactoryGirl.create :user
			    team = organiser.teams_as_organiser.first
			    team.add_follower(local_user)
			    local_user.team_roles.reload
			    event = FactoryGirl.create :event, user: organiser, team: team
			    tse = FactoryGirl.create :teamsheet_entry, user: local_user, event: event
      		event.teamsheet_entries << tse
			   	request.env['X-AUTH-TOKEN'] = local_user.authentication_token

					message_attrs = { text: "text", event_id: event.id }
					post :create, format: :json, message: message_attrs

					response.status.should == 422
				end
			end

			context 'adding a message' do
				it 'returns success' do
					do_create
					response.status.should eq 200
				end

				it 'creates the message on the event' do
					lambda { do_create }.should change(@event.messages, :count).by(1)
				end

				it 'does not star the activity item linked to the message if user is not organiser of the team' do
					#Note we pretend to be the organiser via the role_id however further validation still prevents this action.
					message_attrs = { text: "text", event_id: @event.id, starred: true }
					post :create, format: :json, message: message_attrs

					event_message = @event.messages.last

					meta_data = JSON.parse(event_message.activity_item.meta_data)

					meta_data['starred'].should be_true
					meta_data['starred_at'].should_not be_nil
				end

				it 'star the activity item linked to the message if user is an organiser of the team' do
					@event.team.add_organiser(@user)
					@event.team.reload
					message_attrs = { text: "text", event_id: @event.id, starred: true }
					post :create, format: :json, message: message_attrs

					event_message = @event.messages.last

					meta_data = JSON.parse(event_message.activity_item.meta_data)

					meta_data['starred'].should be_true
					meta_data['starred_at'].should_not be_nil
				end

				it 'returns json containing event information' do
					message_attrs = { text: "text", event_id: @event.id, role_id: PolyRole::ORGANISER, role_type: Team.name }
					post :create, format: :json, message: message_attrs
					parsed_body = JSON.parse(response.body)
					parsed_body['messageable_type'].should == @event.class.name
					parsed_body['messageable'].should_not be_nil
					parsed_body['messageable']['title'].should == @event.title
					parsed_body['messageable']['id'].should == @event.id
					parsed_body['role_type'].should == Team.name
					parsed_body['role_id'].should == PolyRole::ORGANISER
				end

				it 'marks the senders perspetive against the message' do
					message_attrs = { text: "text", event_id: @event.id, role_id: PolyRole::ORGANISER, role_type: Team.name }
					post :create, format: :json, message: message_attrs
					event_message = @event.messages.last
					event_message.sent_as_role_type.should == Team.name
					event_message.sent_as_role_id.should == PolyRole::ORGANISER
				end
			end	

			context 'adding a message to a DemoEvent' do
				before :each do 
					@demo_event = FactoryGirl.create :demo_event, user: @user, team: @user.teams_as_organiser.first
				end

				def do_create	
					message_attrs = { text: "text", event_id: @demo_event.id }
					post :create, format: :json, message: message_attrs
				end

				it 'returns success' do
					do_create
					response.status.should eq 200
				end

				it 'creates the message on the event' do
					lambda { do_create }.should change(@demo_event.messages, :count).by(1)
				end

				it 'does not star the activity item linked to the message if user is not organiser of the team' do
					#Note we pretend to be the organiser via the role_id however further validation still prevents this action.
					message_attrs = { text: "text", event_id: @demo_event.id, starred: true }
					post :create, format: :json, message: message_attrs

					event_message = @demo_event.messages.last

					meta_data = JSON.parse(event_message.activity_item.meta_data)

					meta_data['starred'].should be_true
					meta_data['starred_at'].should_not be_nil
				end

				it 'star the activity item linked to the message if user is an organiser of the team' do
					@demo_event.team.add_organiser(@user)
					@demo_event.team.reload
					message_attrs = { text: "text", event_id: @demo_event.id, starred: true }
					post :create, format: :json, message: message_attrs

					event_message = @demo_event.messages.last

					meta_data = JSON.parse(event_message.activity_item.meta_data)

					meta_data['starred'].should be_true
					meta_data['starred_at'].should_not be_nil
				end

				it 'returns json containing event information' do
					do_create
					parsed_body = JSON.parse(response.body)
					parsed_body['messageable_type'].should == "Event"
					parsed_body['messageable'].should_not be_nil
					parsed_body['messageable']['title'].should == @demo_event.title
					parsed_body['messageable']['id'].should == @demo_event.id
				end
			end	
		end
	end

	context 'team message' do
		before :each do
			@team = FactoryGirl.create :team
			@user = @team.founder
	    request.env['X-AUTH-TOKEN'] = @user.authentication_token
		end

		describe '#create', type: :api do
			def do_create
				message_attrs = { text: "text", team_id: @team.id }
				post :create, format: :json, message: message_attrs
			end

			context 'adding a message' do
				it 'returns success' do
					do_create
					response.status.should eq 200
				end

				it 'creates the message on the team' do
					lambda { do_create }.should change(@team.messages, :count).by(1)
				end

				it 'stars the activity item linked to the message' do
					message_attrs = { text: "text", team_id: @team.id, starred: true }
					post :create, format: :json, message: message_attrs

					team_message = @team.messages.last

					meta_data = JSON.parse(team_message.activity_item.meta_data)

					meta_data['starred'].should be_true
					meta_data['starred_at'].should_not be_nil
				end

				it 'returns json containing team information' do
					do_create
					parsed_body = JSON.parse(response.body)
					parsed_body['messageable_type'].should == @team.class.name
					parsed_body['messageable'].should_not be_nil
					parsed_body['messageable']['name'].should == @team.name
					parsed_body['messageable']['id'].should == @team.id
				end
			end	
		end
	end

	context 'division message' do
		before :each do
		  @league = FactoryGirl.create(:league)
		  @team = FactoryGirl.create :team
		  @division = FactoryGirl.create(:division_season)
		  @division.fixed_division.update_attribute(:league, @league)
		  TeamDSService.add_team(@division, @team)
			@user = @league.organisers.first
	    request.env['X-AUTH-TOKEN'] = @user.authentication_token
		end

		describe '#create', type: :api do
			def do_create
				message_attrs = { text: "text", division_id: @division.id }
				post :create, format: :json, message: message_attrs
			end

			context 'adding a message' do
				it 'returns success' do
					do_create
					response.status.should eq 200
				end

				it 'creates the message on the division' do
					lambda { do_create }.should change(@division.messages, :count).by(1)
				end

				it 'stars the activity item linked to the message' do
					message_attrs = { text: "text", division_id: @division.id, starred: true }
					post :create, format: :json, message: message_attrs

					div_message = @division.messages.last

					meta_data = JSON.parse(div_message.activity_item.meta_data)

					meta_data['starred'].should be_true
					meta_data['starred_at'].should_not be_nil
				end

				it 'returns json containing division information' do
					do_create
					parsed_body = JSON.parse(response.body)
					parsed_body['messageable_type'].should == @division.class.name
					parsed_body['messageable'].should_not be_nil
					parsed_body['messageable']['title'].should == @division.title
					parsed_body['messageable']['id'].should == @division.id
					parsed_body['messageable']['league'].should_not be_nil
					parsed_body['messageable']['league']['id'].should == @league.id
					parsed_body['messageable']['league']['title'].should == @league.title
				end
			end	
		end
	end

	context 'undefined api methods' do
		before :each do
			@user = FactoryGirl.create :user
	    request.env['X-AUTH-TOKEN'] = @user.authentication_token
	    @event = FactoryGirl.create :event, user: @user
		end
		describe '#show', type: :api do
			it 'responds with 501' do
				get :show, id: 1
				response.status.should eq(501)
			end
		end

		describe '#index', type: :api do
			it 'responds with 501' do
				get :show, id: 1
				response.status.should eq(501)
			end
		end

		describe '#update', type: :api do
			it 'responds with 501' do
				put :update, id: 1
				response.status.should eq(501)
			end
		end

		describe '#destroy', type: :api do
			it 'responds with 501' do 
				delete :destroy, id: 1
				response.status.should eq(501)
			end
		end
	end
end
