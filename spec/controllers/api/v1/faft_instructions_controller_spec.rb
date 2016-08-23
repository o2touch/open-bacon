 require 'spec_helper'

describe Api::V1::FaftInstructionsController, :type => :controller  do

  before :each do
    # This stubs out the before_filter of application_controller
    Api::V1::FaftInstructionsController.any_instance.stub(:log_user_activity)
  end

  context '#create_team' do
    before :each do
      @user = FactoryGirl.build :user
      User.stub(find_by_id: @user)

      signed_in @user
      fake_ability
    end

    def do_faft_create(role_id=nil)
      params = {
        id: 124321,
        division_season_id: 2918423,
      }
      post :create_team, faft_team: params, format: :json
    end

    context 'authentication' do
      it 'is not required' do
        signed_out
        do_faft_create
        response.status.should eq(401)
      end
    end

    context 'shit name, we are following. All deprecated anyway. dickheads that do not update their apps' do
      before :each do
        @team = FactoryGirl.create :team
        
        Team.should_receive(:find_by_faft_id).and_return(@team)
      end

      context 'when following' do
        before :each do
          signed_in @user
          fake_ability
        end

        context 'authorization' do
          it 'read is checked and returns 401 if not authed' do
            mock_ability(follow: :fail)
            do_faft_create
            response.status.should eq(401)
          end

          it 'read is checkout and returns 200 if authed' do
            mock_ability(follow: :pass)
            do_faft_create
            response.status.should eq(200)
          end
        end

        it 'does shit' do
          TeamUsersService.should_receive(:add_follower).with(@team, @user, @user).and_return(@team_role)
          AppEventService.should_receive(:create).with(@team_role, @user, "created", anything())
          do_faft_create
          response.status.should eq(200)
        end
      end
    end
  end
end