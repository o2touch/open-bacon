require 'spec_helper'

describe TeamUsersService do
  def mock_team
    mock = double("team")
    mock.stub(id:1)
    mock.stub(goals:GoalChecklist.new)
    mock.stub(schedule_last_sent:true)
    mock.stub(future_events:[])
    mock
  end

  def mock_junior_team

    profile = FactoryGirl.create(:team_profile, :age_group => AgeGroupEnum::UNDER_13)

    mock = double("team")
    mock.stub(id: 1)
    mock.stub(goals: GoalChecklist.new)
    mock.stub(schedule_last_sent: true)
    mock.stub(future_events: [])
    mock.stub(profile: profile)
    mock
  end

  describe "#add_organiser" do
    it 'pervent a user becoming the organiser of to many team' do
      team = FactoryGirl.build(:team)
      user = FactoryGirl.build(:user)
      user.stub(:faft_teams_as_organiser, :count).and_return(MAX_FAFT_TEAMS_ORGANISING)

      expect { TeamUsersService.add_organiser(team, user, true) }.to raise_error 
    end

    it 'should remove any follower roles' do
      team = FactoryGirl.create(:team)
      user = FactoryGirl.create(:user)
      TeamUsersService.should_receive(:add_player).with(team, user, false, nil, true).and_return(true)
      team.add_follower(user)
      TeamUsersService.add_organiser(team, user, true)

      team.has_follower?(user).should be_false
    end

    it 'should add organiser role' do
      team = FactoryGirl.create(:team)
      user = FactoryGirl.create(:user)
      TeamUsersService.should_receive(:add_player).with(team, user, false, nil, true).and_return(true)
      TeamUsersService.add_organiser(team, user, true)

      team.has_organiser?(user).should be_true
    end

    it 'should add team founder' do
      team = FactoryGirl.create(:team, :created_by => nil)
      user = FactoryGirl.create(:user)

      team.founder.should be_nil

      TeamUsersService.should_receive(:add_player).with(team, user, false, nil, true).and_return(true)
      TeamUsersService.add_organiser(team, user, true)

      team.founder.should == user
    end
  end

  describe "#get_user_invite" do

    before :each do
      @user = double("user")
      @user.stub(id: 2)
      @user.stub(email: "tpsherratt@googlemail.com")
      @user.stub(:add_role)
      @user.stub(:delete_role)
      @params = {}

      ti = TeamInvite.create({
        :sent_to_id => @user.id,
        :sent_by_id => 1,
        :team_id => mock_team.id
      })
      ti.save
    end

    context "with id" do

      before :each do
        @invite = TeamUsersService.get_user_invite(mock_team.id, @user)
      end

      it "gets a team invite" do
        @invite.should_not be_nil
      end

      it "gets the right one" do
        @invite.sent_to_id.should == @user.id
        @invite.team_id.should == mock_team.id
      end
    end

    context "with team object" do
      before :each do
        @invite = TeamUsersService.get_user_invite(mock_team, @user)
      end

      it "gets a team invite" do
        @invite.should_not be_nil
      end

      it "gets the right one" do
        @invite.sent_to_id.should == @user.id
        @invite.team_id.should == mock_team.id
      end
    end

  end


  context "for an UNDER_13 team" do

    before :each do
      @profile = FactoryGirl.create(:team_profile, :age_group => AgeGroupEnum::UNDER_13)
      @team = FactoryGirl.build(:team, profile: @profile)
    end

    describe "#add_player" do

      context "with a junior user" do
        it "adds user to the team" do
          user = FactoryGirl.build(:junior_user)
          @team.should_receive(:add_player).with(user)

          TeamUsersService.add_player(@team, user, false)
        end
      end

      context "with an adult user" do
        it "does not add the user" do
          user = FactoryGirl.build(:user)
          @team.should_not_receive(:add_player)

          expect { TeamUsersService.add_player(@team, user, false) }.to raise_error 
        end
      end

    end
  end

  # Under 14-18 teams are treated as adult teams
  context "for an UNDER_14 team" do

    before :each do
      @profile = FactoryGirl.create(:team_profile, :age_group => AgeGroupEnum::UNDER_14)
      @team = FactoryGirl.build(:team, profile: @profile)
    end

    describe "#add_player" do

      context "with a junior user" do
        it "does not add the user" do
          user = FactoryGirl.build(:junior_user)

          expect { TeamUsersService.add_player(@team, user, false) }.to raise_error 
        end
      end

      context "with an adult user" do
        it "adds the user" do
          user = FactoryGirl.build(:user)
          @team.should_receive(:add_player).with(user)

          TeamUsersService.add_player(@team, user, false)
        end
      end

    end
  end

  context "for an ADULT team" do

    before :each do
      @profile = FactoryGirl.create(:team_profile, :age_group => AgeGroupEnum::ADULT)
      @team = FactoryGirl.build(:team, profile: @profile)
    end

    describe "#add_player" do

      context "with a junior user" do
        it "does not add the user" do
          user = FactoryGirl.build(:junior_user)
      
          expect { TeamUsersService.add_player(@team, user, false) }.to raise_error 
        end
      end

      context "with an adult user" do
        it "adds the user" do
          user = FactoryGirl.build(:user)
          @team.should_receive(:add_player).with(user)

          TeamUsersService.add_player(@team, user, false)
        end
      end

    end
  end

  # TODO: #add_follower tests

end