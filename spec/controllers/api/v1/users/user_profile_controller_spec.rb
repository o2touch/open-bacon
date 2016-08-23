require 'spec_helper'

describe Api::V1::Users::UserProfilesController do
  render_views

  let(:team_one){ FactoryGirl.create(:team, :with_players, player_count: 5) }
  let(:team_two){ FactoryGirl.create(:team, :with_players, player_count: 5) }
  let(:team_three){ FactoryGirl.create(:team, :with_players, :with_followers, player_count: 5) }
  let(:user_with_friends_one){ team_one.players.third }
  let(:user_with_friends_two){ team_two.players.third }
  let(:user_three){ FactoryGirl.create(:user) }

  before :each do
    request.env['X-AUTH-TOKEN'] = user_three.authentication_token
  end

  describe '#index', type: :api do
    before :each do
      request.env['X-AUTH-TOKEN'] = user_with_friends_one.friends.first.authentication_token
    end
    context 'when user_id is passed' do 
      before :each do
        get :index, format: :json, user_id: user_with_friends_one.id
      end

      it 'is successful' do
        response.status.should eq(200)
      end
      it 'returns all friends of resource' do
        ids = team_one.members.map{ |member| member.id }
        JSON.parse(response.body).each do |user|
          ids.should include(user.fetch("id"))
        end
      end
    end

    context 'when team_id is passed' do 

      context "when user is player of team" do
        before :each do
          request.env['X-AUTH-TOKEN'] = team_one.players.first.authentication_token
          get :index, format: :json, team_id: team_one.id
        end
        it 'is successful' do
          response.status.should eq(200)
        end
        it 'returns all associates of resource' do
          ids = team_one.associates.map{ |associate| associate.id }
          JSON.parse(response.body).each do |user|
            ids.should include(user.fetch("id"))
          end
        end
      end

      context "when user is follower" do
        before :each do
          request.env['X-AUTH-TOKEN'] = team_three.followers.first.authentication_token
          get :index, format: :json, team_id: team_three.id
        end
        it 'is successful' do
          response.status.should eq(200)
        end
        it 'returns followers of team' do
          ids = team_three.followers.map{ |associate| associate.id }
          JSON.parse(response.body).each do |user|
            ids.should include(user.fetch("id"))
          end
        end
        it 'doesnt return any players of team' do
          ids = team_three.players.map{ |associate| associate.id }
          users = JSON.parse(response.body).map { |u| u.fetch("id") }
          users.each do |id|
            ids.should_not include(id)
          end
        end
      end
    end

    context 'when nothing is passed' do 
      before :each do
        request.env['X-AUTH-TOKEN'] = user_with_friends_two.authentication_token
        get :index, format: :json
      end
      it 'is successful' do
        response.status.should eq(200)
      end
      it 'returns all friends of current user' do
        ids = team_two.members.map{ |member| member.id }
        JSON.parse(response.body).each do |user|
          ids.should include(user.fetch("id"))
        end
      end
    end
  end

  describe '#show', type: :api do
    context 'with valid request' do
      context 'when owner' do
        before :each do
          request.env['X-AUTH-TOKEN'] = user_three.authentication_token
          get :show, format: :json, id: user_three.id
        end
        it 'is successful' do
        response.status.should eq(200)
      end
        it 'returns the users profile' do
          JSON.parse(response.body).fetch("id").should eq(user_three.id)
        end
      end

      # When friend (team member or in an event)
      context 'when friend' do
        before :each do
          request.env['X-AUTH-TOKEN'] = user_with_friends_one.authentication_token
          get :show, format: :json, id: team_one.players.second.id
        end

        it 'is successful' do
          response.status.should eq(200)
        end

        it 'returns the users profile' do
          JSON.parse(response.body).fetch("id").should eq(team_one.players.second.id)
        end
      end

      context 'when not logged in' do
        before :each do
          request.env['X-AUTH-TOKEN'] = nil
          get :show, format: :json, id: user_three.id
        end

        it 'returns 401' do
          response.status.should eq(401)
        end
      end
    end

    context 'with invalid request' do
      it 'raises a RecordNotFound exception' do
        get :show, format: :json, id: -1
        response.status.should eq(404)
      end
    end
  end

  # This shit is currently handled by the user registrations controller
  describe '#create', type: :api do
    context 'with valid request' do
      context 'when logged in' do
        it 'is successful' 
        it 'creates resource and returns the users profile'
      end

      context 'when unauthorized' do 
        it 'returns 401 unauthorized'
      end
    end
  end

  describe '#update', type: :api do
    context 'with valid request' do
      context 'when owner' do
        before :each do
          request.env['X-AUTH-TOKEN'] = user_three.authentication_token
          user_attrs = user_three.attributes
          @name = "Timothy 'the winner' Sherratt"
          user_attrs[:name] = @name
          put :update, format: :json, id: user_three.id, user: user_attrs
        end
        it 'is successful' do
          response.status.should eq(200)
        end
        it 'updates the resource' do
          user_three.reload
          user_three.name.should eq(@name)
        end
        it 'returns the resource' do
          JSON.parse(response.body).fetch("id").should eq(user_three.id)
        end
      end

      # Team organisers are able to update a user, if that user has not logged in and set a password (ie, still has the "invited" role")
      context 'when team organiser' do
        before :each do
          request.env['X-AUTH-TOKEN'] = team_one.organisers.first.authentication_token
          @user_attrs = user_with_friends_one.attributes
          @old_name = user_with_friends_one.name
          @name = "Timothy 'the winner' Sherratt"
          @user_attrs[:name] = @name
        end
        context 'when resource has invited role' do
          before :each do
            user_with_friends_one.delete_role RoleEnum::REGISTERED
            user_with_friends_one.add_role RoleEnum::INVITED

            put :update, format: :json, id: user_with_friends_one.id, user: @user_attrs
          end
          it 'is successful' do
            response.status.should eq(200)
          end
          it 'updates the resource' do
            user_with_friends_one.reload
            user_with_friends_one.name.should eq(@name)
          end
          it 'returns the resource' do
            JSON.parse(response.body).fetch("id").should eq(user_with_friends_one.id)
          end
        end

        context 'when resource is active user' do
          before :each do
            user_with_friends_one.add_role RoleEnum::REGISTERED
            user_with_friends_one.delete_role RoleEnum::INVITED

            put :update, format: :json, id: user_with_friends_one.id, user: @user_attrs
          end
          it 'returns 401 unauthorized' do
            response.status.should eq(401)
          end
          it 'does not update the users profile' do
            user_with_friends_one.reload
            user_with_friends_one.name.should eq(@old_name)
          end
        end
      end
    end

    context 'when invalid request' do
      it 'raises a RecordNotFound exception' do
        request.env['X-AUTH-TOKEN'] = team_one.organisers.first.authentication_token
        put :update, format: :json, id: -1
        response.status.should eq(404)
      end
    end
  end

  describe '#destroy', type: :api do
    it 'responds with 501 (not implemented)' do
      delete :destroy, format: :json, id: 1
      response.status.should eq(501)
    end
  end

end