require 'spec_helper'

describe Api::V1::M::HomeCardsController do

	describe '#index' do

		context "with a full activity" do

			before :each do
				
				@division = FactoryGirl.create :division_season
				@division.stub(:id).and_return(1)

				@user = FactoryGirl.create :user, :with_teams, :team_count => 1
				@team = @user.teams_as_organiser.first
				@away_team = @division.teams.last

				@event = FactoryGirl.create :event, user: @user, team: @team
				@event2 = FactoryGirl.create :event, user: @user, team: @team
				@event3 = FactoryGirl.create :event, user: @user, team: @team

				TeamDSService.add_team(@division, @team)
				
				@fixture = FactoryGirl.create(:fixture, :division_season => @division)
				@fixture.manual_override!
				@fixture.home_team = @team
				@fixture.home_event = @event
				@fixture.away_team = @away_team
				@fixture.publish_edits!

				@fixture2 = FactoryGirl.create(:fixture, :division_season => @division)
				@fixture2.manual_override!
				@fixture2.home_team = @team
				@fixture2.home_event = @event2
				@fixture2.away_team = @away_team
				@fixture2.publish_edits!

				# Result
				@result = FactoryGirl.create(:soccer_result)

				@fixture3 = FactoryGirl.create(:fixture, :division_season => @division, :time => (Time.now - 2.days))
				@fixture3.manual_override!
				@fixture3.home_team = @team
				@fixture3.home_event = @event3
				@fixture3.away_team = @away_team
				@fixture3.result = @result
				@fixture3.publish_edits!

				dp = DivisionPresenter.new(@division)

				# Team Stats
				@position = dp.standings_position(@team)
				@played = dp.games_played(@team)
				@won = dp.games_won(@team)
				@form	= dp.form_guide(@team)

				request.env['X-AUTH-TOKEN'] = @user.authentication_token
			end

			it 'displays next fixture card' do
				
				home_team_str = @fixture.home_team?(@event.team) ? "home" : "away"

				get :index, format: :json, user_id: @user.id

				r = JSON.parse(response.body)

				r.size.should == 4

				result_obj = r[0]
				result_obj["type"].should == "next_fixture"
				result_obj["header_text"].should == "<#{@fixture.home_team.name}> - Next game"
				result_obj["obj_type"].should == "fixture"

				result_obj["obj"]["home_team"]["id"].should == @fixture.home_team_id
				result_obj["obj"]["home_team"]["name"].should == @fixture.home_team.name
				result_obj["obj"]["home_team"]["colour1"].should == @fixture.home_team.profile.colour1
				result_obj["obj"]["home_team"]["profile_picture_small_url"].should == @fixture.home_team.profile.profile_picture_small_url

				unless @fixture.away_team.nil?
					result_obj["obj"]["away_team"]["id"].should == @fixture.away_team_id
					result_obj["obj"]["away_team"]["name"].should == @fixture.away_team.name
					result_obj["obj"]["away_team"]["colour1"].should == @fixture.away_team.profile.colour1
					result_obj["obj"]["away_team"]["profile_picture_small_url"].should == @fixture.away_team.profile.profile_picture_small_url
				else
					result_obj["obj"]["away_team"].should be_nil
				end

				result_obj["data"]["home_or_away"].should == home_team_str
				result_obj["data"]["linked_event"]["id"].should == @event.id
				result_obj["data"]["linked_event"]["team"]["id"].should == @event.team.id

			end

			it 'displays fixture result card' do
				
				home_team_str = @fixture.home_team?(@event.team) ? "home" : "away"

				get :index, format: :json, user_id: @user.id

				r = JSON.parse(response.body)

				r.size.should == 4

				result_obj = r[1]
				result_obj["type"].should == "fixture_result"
				result_obj["header_text"].should == "<#{@fixture3.home_team.name}> - Last result"
				result_obj["obj_type"].should == "fixture"

				result_obj["obj"]["id"].should == @fixture3.id
				result_obj["obj"]["status"].should == @fixture3.status
				result_obj["obj"]["home_team"]["id"].should == @fixture3.home_team_id
				result_obj["obj"]["home_team"]["name"].should == @fixture3.home_team.name
				result_obj["obj"]["home_team"]["colour1"].should == @fixture3.home_team.profile.colour1
				result_obj["obj"]["home_team"]["profile_picture_small_url"].should == @fixture.home_team.profile.profile_picture_small_url

				unless @fixture3.away_team.nil?
					result_obj["obj"]["away_team"]["id"].should == @fixture3.away_team_id
					result_obj["obj"]["away_team"]["name"].should == @fixture3.away_team.name
					result_obj["obj"]["away_team"]["colour1"].should == @fixture3.away_team.profile.colour1
					result_obj["obj"]["away_team"]["profile_picture_small_url"].should == @fixture.away_team.profile.profile_picture_small_url
				else
					result_obj["obj"]["away_team"].should be_nil
				end

				result_obj["obj"]["result"]["home_final_score_str"] == @result.home_score[:full_time]
				result_obj["obj"]["result"]["away_final_score_str"] == @result.away_score[:full_time]
				result_obj["obj"]["result"]["home_team_won"] == @result.home_team_won?
				result_obj["obj"]["result"]["away_team_won"] == @result.away_team_won?

				result_obj["data"]["home_or_away"].should == home_team_str
				result_obj["data"]["linked_event"]["id"].should == @event3.id
				result_obj["data"]["linked_event"]["team"]["id"].should == @event3.team.id
			end

			it 'displays stats card' do
				
				get :index, format: :json, user_id: @user.id

				r = JSON.parse(response.body)

				r.size.should == 4

				result_obj = r[2]
				result_obj["type"].should == "team_stats"
				result_obj["header_text"].should == "<#{@fixture3.home_team.name}> - Stats"
				result_obj["obj_type"].should == "team"

				result_obj["obj"]["id"].should == @fixture3.home_team_id

				result_obj["data"]["position"].should == @position
				# result_obj["data"]["form"].should == @form
				result_obj["data"]["played"].should == @played
				result_obj["data"]["won"].should == @won
			end

			it 'displays division card' do
				
				get :index, format: :json, user_id: @user.id

				r = JSON.parse(response.body)

				r.size.should == 4

				result_obj = r[3]
				result_obj["type"].should == "division_results"
				result_obj["header_text"].should == "<#{@division.title}> - Latest results"
				result_obj["obj_type"].should == "division"

				result_obj["obj"]["id"].should == @division.id
				result_obj["obj"]["league"]["id"].should == @division.league.id

				result_obj["data"]["team"]["id"].should == @team.id
			end
		end

		context "with nothing to display" do

			before(:each) do
				@user = FactoryGirl.create :user, :with_teams, :team_count => 1
				@team = @user.teams_as_organiser.first

				request.env['X-AUTH-TOKEN'] = @user.authentication_token
			end

			it 'returns an empty feed' do
				
				get :index, format: :json, user_id: @user.id

				r = JSON.parse(response.body)
				r.size.should == 0
			end
		end

		context "with two teams in same division" do

			before(:each) do
				@division = FactoryGirl.create :division_season
				@division.stub(:id).and_return(1)

				@user = FactoryGirl.create :user, :with_teams, team_count: 2

				@user.teams_as_organiser.each do |t|
					TeamDSService.add_team(@division, t)
				end

				# Result
				@result = FactoryGirl.create(:soccer_result)

				@fixture3 = FactoryGirl.create(:fixture, division_season: @division, time: (Time.now - 2.days))
				@fixture3.manual_override!
				@fixture3.home_team = @division.teams.first
				@fixture3.home_event = nil
				@fixture3.away_team = @away_team
				@fixture3.result = @result
				@fixture3.publish_edits!

				@division.stub(:past_fixtures).and_return([@fixture3])

				request.env['X-AUTH-TOKEN'] = @user.authentication_token
			end

			it 'returns an empty feed' do
				
				get :index, format: :json, user_id: @user.id

				r = JSON.parse(response.body)

				division_results_count = 0
				r.each do |card|
					division_results_count += 1 if card['type']=='division_results'
				end

				r.size.should == 4
				division_results_count.should == 1
			end
		end

		context 'when requesting tenanted shit' do
			before(:each) do
				@division_one = FactoryGirl.create :division_season
				@division_two = FactoryGirl.create :division_season
				@division_one.stub(:id).and_return(1)
				@division_two.stub(:id).and_return(2)

				@user = FactoryGirl.create :user, :with_teams, :team_count => 2

				t1 = @user.teams.first
				t1.tenant = Tenant.find(1)
				t1.save!
				t2 = @user.teams.second
				t2.tenant = Tenant.find(2)
				t2.save!

				TeamDSService.add_team(@division_one, @user.teams.first)
				TeamDSService.add_team(@division_two, @user.teams.second)

				# Result
				@result = FactoryGirl.create(:soccer_result)

				@fixture3 = FactoryGirl.create(:fixture, :division_season => @division_one, :time => (Time.now - 2.days))
				@fixture3.manual_override!
				@fixture3.home_team = @division_one.teams.first
				@fixture3.home_event = nil
				@fixture3.away_team = @away_team
				@fixture3.result = @result
				@fixture3.publish_edits!

				@division_one.stub(:past_fixtures).and_return([@fixture3])

				@result = FactoryGirl.create(:soccer_result)

				@fixture4 = FactoryGirl.create(:fixture, :division_season => @division_two, :time => (Time.now - 2.days))
				@fixture4.manual_override!
				@fixture4.home_team = @division_two.teams.first
				@fixture4.home_event = nil
				@fixture4.away_team = @away_team
				@fixture4.result = @result
				@fixture4.publish_edits!

				@division_two.stub(:past_fixtures).and_return([@fixture4])

				request.env['X-AUTH-TOKEN'] = @user.authentication_token
			end
			it 'should return everything when using the mitoo app' do
				request.env['X-APP-ID'] = MobileApp.find(1).token
				get :index, format: :json, user_id: @user.id
				JSON.parse(response.body).count.should eq(6)
			end
			it 'should return only o2 stuff when using the mitoo app' do
				request.env['X-APP-ID'] = MobileApp.find(2).token
				get :index, format: :json, user_id: @user.id
				JSON.parse(response.body).count.should eq(3)
			end
		end
	end
end