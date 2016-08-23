require 'spec_helper'

describe Api::V1::Users::TeamNotificationSettingsController do
  # render_views

  let(:team){ FactoryGirl.create(:team, :with_players, player_count: 5) }
  let(:team1){ FactoryGirl.create(:team, :with_players, player_count: 5) }
  let(:team2){ FactoryGirl.create(:team, :with_players, player_count: 5) }
  let(:user){ FactoryGirl.create(:user) }

  before :each do
    request.env['X-AUTH-TOKEN'] = user.authentication_token
  end

  describe '#index' do

  end

  describe '#index' do

    context 'when user_id is passed' do

      before :each do
  
        setting = FactoryGirl.build :users_teams_notification_setting, notification_key: 'messaging_availability', value: true

        @settings = [
          setting
        ]

        @abilities = Ability.new(user)
        @abilities.stub(:can?).with(:update, user).and_return(true)
        Ability.stub(:new).and_return(@abilities)

        UsersTeamsNotificationSetting.should_receive(:get_all_settings).with(user, team1).and_return(@settings)
        UsersTeamsNotificationSetting.should_receive(:get_all_settings).with(user, team2).and_return(@settings)

        User.stub(:find).and_return(user)
        user.stub(:teams).and_return([team1, team2])

        get :index, format: :json, id: user.id
      end

      it 'is successful' do
        response.status.should eq(200)
      end

      it 'returns the settings' do
        data = JSON.parse(response.body)
        data.size.should == 2
      end
    end

    context 'when no permissions' do

      before :each do
  
        setting = FactoryGirl.build :users_teams_notification_setting, notification_key: 'messaging_availability', value: true

        @settings = [
          setting
        ]
  
        @abilities = Ability.new(user)
        @abilities.stub(:can?).with(:update, user).and_return(false)
        Ability.stub(:new).and_return(@abilities)

        UsersTeamsNotificationSetting.should_not_receive(:get_all_settings)

        get :index, format: :json, id: user.id
      end

      it 'is unauthorized' do
        response.status.should eq(401)
      end
    end
  end


  describe '#show' do

    context 'when user_id is passed' do

      before :each do
  
        setting = FactoryGirl.build :users_teams_notification_setting, notification_key: 'messaging_availability', value: true

        @settings = [
          setting
        ]

        @abilities = Ability.new(user)
        @abilities.stub(:can?).with(:update, user).and_return(true)
        @abilities.stub(:can?).with(:read_notification_settings, anything()).and_return(true)

        Ability.stub(:new).and_return(@abilities)

        UsersTeamsNotificationSetting.should_receive(:get_all_settings).with(user, team).and_return(@settings)

        get :show, format: :json, id: user.id, team_id: team.id
      end

      it 'is successful' do
        response.status.should eq(200)
      end

      it 'returns the settings' do
        data = JSON.parse(response.body)
        data['messaging_availability'].should == true
      end
    end

    context 'when no permissions' do

      before :each do
  
        setting = FactoryGirl.build :users_teams_notification_setting, notification_key: 'messaging_availability', value: true

        @settings = [
          setting
        ]
  
        @abilities = Ability.new(user)
        @abilities.stub(:can?).with(:update, user).and_return(true)
        @abilities.stub(:can?).with(:read_notification_settings, anything()).and_return(false)

        Ability.stub(:new).and_return(@abilities)

        UsersTeamsNotificationSetting.should_not_receive(:get_all_settings)

        get :show, format: :json, id: user.id, team_id: team.id
      end

      it 'is unauthorized' do
        response.status.should eq(401)
      end
    end

  end

  describe '#update', type: :api do
    context 'when user_id is passed' do

      before :each do
        @settings = {
          'messaging_availability' => true
        }

        @abilities = Ability.new(user)
        @abilities.stub(:can?).with(:update, user).and_return(true)
        @abilities.stub(:can?).with(:update_notification_settings, anything()).and_return(true)

        Ability.stub(:new).and_return(@abilities)

        put :update, format: :json, id: user.id, team_id: team.id, settings: @settings
      end

      it 'is successful' do
        response.status.should eq(200)
      end

      it 'updates the settings' do
        data = JSON.parse(response.body)
        data['messaging_availability'].should == true
      end
    end

    context 'when user does not have permissions for team' do
      before :each do
        @settings = {
          'messaging_availability' => true
        }

        @abilities = Ability.new(user)
        @abilities.stub(:can?).with(:update, user).and_return(true)
        @abilities.stub(:can?).with(:update_notification_settings, anything()).and_return(false)

        Ability.stub(:new).and_return(@abilities)

        put :update, format: :json, id: user.id, team_id: team.id, settings: @settings
      end

      it 'is successful' do
        response.status.should eq(401)
      end
    end

    context 'when there is a problem with parameters' do
      it 'returns an error' do
        put :update, format: :json, id: user.id, team_id: team.id
        response.status.should eq(422)
      end
      it 'returns an error' do
        put :update, format: :json, id: user.id, settings: {}
        response.status.should eq(422)
      end
      it 'returns an error' do
        put :update, format: :json, team_id: team.id, settings: {}
        response.status.should eq(422)
      end
    end
  end

  describe '#create', type: :api do
    it 'responds with 501 (not implemented)' do
      post :create, format: :json, id: 1
      response.status.should eq(501)
    end
  end

  describe '#destroy', type: :api do
    it 'responds with 501 (not implemented)' do
      delete :destroy, format: :json, id: 1
      response.status.should eq(501)
    end
  end

end