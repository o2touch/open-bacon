require 'spec_helper'

# TODO Create API::V1::TeamsController and remove String from below
describe Api::V1::TeamsController do
  render_views

  let(:team){ FactoryGirl.create(:team) }
  let(:owner){ team.created_by }
  let(:other_user){ FactoryGirl.create(:user) }
  let(:multi_team_user) do
    # a team for us not to get back from #index
    mtu = FactoryGirl.create(:user, :with_teams, team_count: 3)
    TeamUsersService.add_player(team, mtu, false)
    mtu
  end
  let(:player) do
    player = FactoryGirl.create(:user)
    TeamUsersService.add_player(team, player, false)
    player
  end

  before :each do
    AppEventService.stub(:create)
    Api::V1::TeamsController.any_instance.stub(:log_user_activity)
  end

  def set_token(u)
    request.env['X-AUTH-TOKEN'] = u.authentication_token
  end

  describe '#index', type: :api do
    context 'when ids is passed' do
      before :each do
        user = FactoryGirl.create(:user)
        signed_in user
      end

      def do_ids_index(ids=[1,2,3,4])
        get :index, format: :json, ids: ids
      end

      it 'is successful (even if no teams)' do
        do_ids_index
        response.status.should eq(200)
      end

      it 'returns the requested teams' do
        Team.should_receive(:find_by_id).with(1).and_return(FactoryGirl.build :team)
        Team.should_receive(:find_by_id).with(2).and_return(FactoryGirl.build :team)
        Team.should_receive(:find_by_id).with(3).and_return(FactoryGirl.build :team)
        Team.should_receive(:find_by_id).with(4).and_return(FactoryGirl.build :team)
        do_ids_index
        JSON.parse(response.body).count.should eq(4)
      end

      it 'errors if the request is too big' do
        ids = []
        (1..202).each{ |id| ids << id }
        do_ids_index(ids)
        response.status.should eq(422)
      end
    end

    context 'when user_id param is passed' do 
      before :each do
        set_token owner
        get :index, format: :json, user_id: multi_team_user.id
      end

      it 'is successful' do
        response.status.should eq(200)
      end

      it 'should return all teams for resource' do
        teams = JSON.parse(response.body)
        ids = multi_team_user.teams.map{ |t| t.id }
        teams.each do |t|
          ids.should include(t.fetch("id"))
        end 
        teams.count.should eq(multi_team_user.teams.count)
      end
    end

    context 'when nothing is not passed' do 
      before :each do
        set_token multi_team_user
        get :index, format: :json
      end

      it 'is successful' do
        response.status.should eq(200)
      end

      it 'should return all teams for current user' do
        teams = JSON.parse(response.body)
        ids = multi_team_user.teams.map{ |team| team.id }
        teams.each do |team|
          ids.should include(team.fetch("id"))
        end 
      end
    end
  end

  describe '#send_schedule' do
    it 'creates an app event' do
      @user = FactoryGirl.build(:user)
      signed_in(@user)
      fake_ability
      @team = FactoryGirl.build :team
      Team.stub(find: @team)
      # nolonger sending out this notification... TS
      AppEventService.should_not_receive(:create)#.with(@team, @user, "schedule_updated")
      post :send_schedule, format: :json, id: 1
    end
  end

  describe '#create', type: :api do
    def do_create(attrs={})
      team_attrs = {
        name: "Team Tim",
        colour1: ColourEnum.values.sample,
        colour2: ColourEnum.values.sample,
        sport: SportsEnum.values.sample,
        age_group: AgeGroupEnum::ADULT,
        tenant_id: 1,
      }
      attrs[:format] = :json
      attrs[:team] = team_attrs
      post :create, attrs
    end
    context 'when logged in' do
      it 'is successful' do 
        set_token owner
        do_create
        response.status.should eq(200)
      end

      it 'creates a team' do
        set_token owner
        lambda{ do_create }.should change(Team, :count).by(1)
      end

      it 'creates a team profile' do
        set_token owner
        lambda{ do_create }.should change(TeamProfile, :count).by(1)
      end

      it 'sets default team colours, if non are supplied' do
        owner.teams_as_organiser.first.profile.colour1 = DefaultColourEnum::DEFAULT_1
        owner.teams_as_organiser.first.profile.colour1 = DefaultColourEnum::DEFAULT_2
      end

      it 'associates the resource with the current_user' do
        set_token owner
        lambda{ do_create }.should change(owner.teams_as_organiser, :count).by(1)
      end

      it 'does not do league stuff, if no division_id provided' do
        set_token owner
        DivisionSeason.should_not_receive(:find)
        do_create
      end

      it 'should add them to the div, if appropriate' do
        set_token owner

        @div = FactoryGirl.create(:division_season)
        @div.config.applications_open = true

        DivisionSeason.should_receive(:find).and_return(@div)
        TeamDSService.should_receive(:add_pending_team).with(@div, kind_of(Team))

        do_create(division_id: 100)

        response.status.should eq(200)
      end
    end

    context 'when logged out' do
      it 'return 401 unauthorized' do
        do_create
        response.status.should eq(401)
      end
    end
  end

  describe '#show', type: :api do
    context 'with valid request' do
      def do_show
        get :show, format: :json, id: team.id
      end

      context 'when owner' do
        it 'is successful' do
          set_token owner
          do_show
          response.status.should eq(200)
        end

        it 'returns the team resource' do
          set_token owner 
          do_show
          JSON.parse(response.body).fetch("id").should eq(team.id)
        end
      end

      context 'when team member' do
        it 'is successful' do
          set_token player
          do_show
          response.status.should eq(200)
        end

        it 'returns the team resource' do
          set_token player
          do_show
          JSON.parse(response.body).fetch("id").should eq(team.id)
        end
      end

      context 'when logged out' do 
        it 'returns 401 unauthorized' do
          do_show
          response.status.should eq(401)
        end
      end
    end

    context 'with invalid request' do
      it 'raises a RecordNotFound exception' do
        set_token owner
        get :show, format: :json, id: -1
        response.status.should eq(404)
      end
    end
  end

  describe '#update', type: :api do
    def do_update(id=nil)
      @name = "TIM TEAM"
      @sport = SportsEnum::CYCLING
      team_attrs = team.attributes
      id ||= team_attrs["id"]
      team_attrs["name"] = @name
      team_attrs["sport"] = @sport
      team_attrs["age_group"] = AgeGroupEnum::ADULT
      put :update, format: :json, id: id, team: team_attrs 
    end
     
    context 'when authorized' do
      it 'is successful' do
        set_token owner
        do_update
        response.status.should eq(200)
      end

      it 'updates the team' do
        set_token owner
        do_update
        team.reload
        team.name.should eq(@name)
      end

      it 'updates the team profile' do
        set_token owner
        do_update
        team.reload
        team.profile.sport.should eq(@sport)
      end
    end

    context 'when wrong or incorrect team_id is passed' do
      it 'raises a RecordNotFound exception' do
        set_token owner
        do_update(-1)
        response.status.should eq(404)
      end
    end

    context 'when unauthorized' do 
      it 'returns 401 unauthorized' do
        do_update
        response.status.should eq(401)
      end
      it 'does not update the team' do
        team_name = team.name
        do_update
        team.name.should eq(team_name)
      end
    end
  end

context '#follow' do
    context "as an existing user" do

      before :each do
        @user = FactoryGirl.build :user
        User.stub(find_by_id: @user)

        signed_in @user
        fake_ability
      end

      def do_follow(role_id=nil)
        params = {
          id: 124321
        }
        post :follow, team: params, format: :json
      end

      context 'authentication' do
        it 'is not required' do
          signed_out
          do_follow
          response.status.should eq(401)
        end
      end

      context 'and an existing team' do
        before :each do
          @team = FactoryGirl.create :team
          
          Team.should_receive(:find).and_return(@team)
        end

        context 'when following' do
          before :each do
            signed_in @user
            fake_ability
          end

          context 'authorization' do
            it 'read is checked and returns 401 if not authed' do
              mock_ability(follow: :fail)
              do_follow
              response.status.should eq(401)
            end

            it 'read is checkout and returns 200 if authed' do
              mock_ability(follow: :pass)
              do_follow
              response.status.should eq(200)
            end
          end

          it 'does shit' do
            TeamUsersService.should_receive(:add_follower).with(@team, @user, @user).and_return(@team_role)
            AppEventService.should_receive(:create).with(@team_role, @user, "created", anything())
            do_follow
            response.status.should eq(200)
          end
        end
      end
    end
  end

  describe '#send_activation_links', type: :api do
    context "when user is provided" do

      before :each do
        @user = FactoryGirl.build :user
        User.stub(find_by_id: @user)

        @team = FactoryGirl.create :team
        Team.stub(:find).and_return(@team)

        @params = {
          id: "124321"
        }

        signed_in @user
        fake_ability
      end

      def do_send_activation_link
        post :send_activation_links, @params, format: :json
      end

      context 'authentication' do
        it 'is required' do
          signed_out
          do_send_activation_link
          response.status.should eq(401)
        end

        it 'manage ability is checked and fails' do
          mock_ability(manage: :fail)

          do_send_activation_link
          response.status.should eq(401)
        end

        it 'manage ability is checked and passes' do
          mock_ability(manage: :pass)

          do_send_activation_link
          response.status.should eq(200)
        end
      end

      context 'when O2Touch team' do
        
        before :each do
          @team.stub(:is_o2_touch_team?).and_return(true)

          Team.should_receive(:find).with(@params[:id])

          # Assuming that team.organisers method returns an array of organisers
          # Set-up the organiser with different
          @user1 = FactoryGirl.create :user
          @user1.stub(:has_activated_account?).and_return(true)

          @user2 = FactoryGirl.create :user
          @user2.stub(:has_activated_account?).and_return(false)

          @users = [@user1, @user2]
        end

        context 'and has organisers' do
          it 'it sends activation emails' do
            signed_in @user

            @team.should_receive(:organisers).and_return(@users)
            AppEventService.should_not_receive(:create).with(@team, @user1, anything(), anything())
            AppEventService.should_receive(:create).with(@team, @user2, "organiser_imported", { processor: 'Ns2::Processors::O2TouchProcessor' })

            do_send_activation_link
          end
        end

        context 'and has players' do
          it 'it sends activation emails' do
            signed_in @user
            @team.should_receive(:organisers).and_return([])
            @team.should_receive(:players).and_return(@users)
            AppEventService.should_not_receive(:create).with(@team, @user1, anything(), anything())
            AppEventService.should_receive(:create).with(@team, @user2, "player_imported", { processor: 'Ns2::Processors::O2TouchProcessor' })

            do_send_activation_link
          end
        end
      end

      context 'when Mitoo team' do
        
        before :each do
          @team.stub(:is_o2_touch_team?).and_return(false)
          Team.should_receive(:find).with(@params[:id])

          # Assuming that team.organisers method returns an array of organisers
          # Set-up the organiser with different
          @user1 = FactoryGirl.create :user
          @user1.stub(:has_activated_account?).and_return(true)

          @user2 = FactoryGirl.create :user
          @user2.stub(:has_activated_account?).and_return(false)

          @users = [@user1, @user2]
        end

        context 'and has organisers' do
          it 'it sends activation emails' do
            signed_in @user

            @team.should_receive(:organisers).and_return(@users)
            AppEventService.should_not_receive(:create).with(@team, @user1, anything(), anything())
            AppEventService.should_receive(:create).with(@team, @user2, "organiser_imported", anything())

            do_send_activation_link
          end
        end

        context 'and has players' do
          it 'it sends activation emails' do
            signed_in @user
            @team.should_receive(:organisers).and_return([])
            @team.should_receive(:players).and_return(@users)
            AppEventService.should_not_receive(:create).with(@team, @user1, anything(), anything())
            AppEventService.should_receive(:create).with(@team, @user2, "player_imported", anything())

            do_send_activation_link
          end
        end
      end
    end
  end

  describe '#destroy', type: :api do
    it 'responds with 501 (not implemented)' do 
      set_token owner
      delete :destroy, format: :json, id: 1
      response.status.should eq(501)
    end
  end
end