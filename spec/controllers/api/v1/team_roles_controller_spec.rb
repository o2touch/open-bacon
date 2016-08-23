require 'spec_helper'

describe Api::V1::TeamRolesController, :type => :controller  do

  let(:team) { FactoryGirl.create(:team) }
  
  let(:faft_team) { 
    FactoryGirl.create(:team).tap do |t|
      t.stub(:faft_team?).and_return(true)
      t.organisers = []
    end
  }

  let(:founder) { team.founder }
  let(:junior) do
    FactoryGirl.create(:junior_user).tap { |user| team.add_player(user) }
  end
  let(:player) do
    FactoryGirl.create(:user).tap { |user| team.add_player(user) }
  end
  let(:follower) do
    FactoryGirl.create(:user).tap { |user| team.add_follower(user) }
  end
  let(:organiser) do
    FactoryGirl.create(:user).tap { |user| team.add_organiser(user) }
  end
  let(:parent) do
    junior.parents.first.tap { |user| team.add_parent(user) }
  end
  let(:new_user) do
    FactoryGirl.create(:user)
  end

  before :each do
    @team_role = double("team_role")
    AppEventService.stub(:create)
  end

  def find_team_role(user, team, role)
    PolyRole.find(:all, :conditions => 
      { :role_id => role, :user_id => user.id, :obj_type => 'Team', :obj_id => team.id })
  end

  context "#destroy" do
    before :each do
      sign_in follower
      EmailNotificationService.stub(:notify_destroyed_team_role)
      team.goals.stub(:notify)
    end
     def do_destroy(user, team, role)
      roles = find_team_role(user, team, role)
      roles.count.should eq(1)
      role = roles.first
      role.should_not be_nil
      team.reload
      delete :destroy, id: role.id, format: :json
    end
    
    context 'removing a follower' do 
      it 'should remove the follower role' do
        do_destroy(follower, team, PolyRole::FOLLOWER)
        team.followers.should_not include follower
      end
    end
  end

  context "#destroy" do
    before :each do
      sign_in founder
      EmailNotificationService.stub(:notify_destroyed_team_role)
      team.goals.stub(:notify)
    end

    def do_destroy(user, team, role)
      roles = find_team_role(user, team, role)
      roles.count.should eq(1)
      role = roles.first
      role.should_not be_nil
      team.reload
      delete :destroy, id: role.id, format: :json
    end

    context 'removing a player' do
      it 'should remove the player role' do
        do_destroy(player, team, PolyRole::PLAYER)
        team.players.should_not include player
      end

      it 'should remove the player from future events' do
        TeamUsersService.should_receive(:remove_player_from_team).with(team, player)
        do_destroy(player, team, PolyRole::PLAYER)
      end
    end

    context 'removing a follower' do 
      it 'should remove the follower role' do
        do_destroy(follower, team, PolyRole::FOLLOWER)
        team.followers.should_not include follower
      end
    end

    context 'removing an organiser' do 
      it 'should remove the organiser role' do
        do_destroy(organiser, team, PolyRole::ORGANISER)
        team.organisers.should_not include organiser
      end
    end

    context 'removing a parent' do 
      it 'should remove the parent role' do
        parent.children.each { |child| team.revoke_role(PolyRole::PLAYER, child) }
        do_destroy(parent, team, PolyRole::PARENT)
        team.parents.should_not include parent
      end
    end

    it 'returns 204 if successful' do
      do_destroy(player, team, PolyRole::PLAYER)
      response.status.should eq(204)
    end

    it 'should reduce the team role count by one' do
      player #Creates player role
      expect { do_destroy(player, team, PolyRole::PLAYER) }.to change{ PolyRole.count }.by(-1)
    end

    it 'returns 401 if a user tries to delete their own roles' do
      #Should this be 406?
      team.add_player(founder)
      do_destroy(founder, team, PolyRole::PLAYER)
      response.status.should eq(401)
    end

    it 'returns 412 if a user tries to remove a parent before removing the parents children' do
      parent.children.count.should > 0
      do_destroy(parent, team, PolyRole::PARENT)
      response.status.should eq(412)
      JSON.parse(response.body)['errors'].should include 'Remove the users children from the team first.'
    end
  end

 
  context "#create" do
    before :each do
      EmailNotificationService.stub :notify_destroyed_team_role
      team.goals.stub(:notify)
    end

    def do_create(team_obj, user, role)
      params = {
        :team_id => team_obj.id,
        :user_id => user.id,
        :role_id => role
      }

      post :create, :team_role => params, format: :json
      team_obj.reload
    end

    context 'logged in user not in the team' do
      before :each do
        sign_in new_user
        Team.stub(:find => team)
      end

      context 'should allow the user to follow a followable team' do
        before :each do
          team.config.team_followable = true
          team.save
          do_create(team, new_user, PolyRole::FOLLOWER)
        end

        it 'makes the user a follower' do 
          team.followers.should include new_user
        end

        it 'returns 201 if successful' do
          response.status.should eq(200)
        end
      end

      context 'should not allow the user to follow an unfollowable team' do
        before :each do
          team.config.team_followable = false
          team.save
          do_create(team, new_user, PolyRole::FOLLOWER)
        end

        it 'should not make the user a follower' do 
          team.followers.should_not include new_user
        end

        it 'returns 401' do
          response.status.should eq(401)
        end
      end

      context 'should not allow the user to add other followers to a team' do
        before :each do
          team.stub(:is_public? => true)
          @another_new_user = FactoryGirl.create(:user)
          do_create(team, @another_new_user, PolyRole::FOLLOWER)
        end

        it 'should not make the other user a follower' do 
          team.followers.should_not include @another_new_user
        end

        it 'returns 401' do
          response.status.should eq(401)
        end
      end
    end

    context 'logged in team follower' do
      context 'team with no organiser' do 
        before :each do
          faft_team.add_follower(follower)
          Team.stub(:find).and_return(faft_team)
          sign_in follower
          do_create(faft_team, follower, PolyRole::ORGANISER)
        end

        it 'makes the follower an organiser' do
          faft_team.organisers.should include follower
        end

        it 'remove the follower role from the follower' do
          faft_team.followers.should_not include follower
        end

        it 'returns 200' do
          response.status.should eq(200)
        end
      end

      context 'team with organiser' do 
        before :each do
          team.stub(:faft_team?).and_return(true)
          Team.stub(:find).and_return(team)
          sign_in follower
          do_create(team, follower, PolyRole::ORGANISER)
        end

        it 'does not make the follower an organiser' do
          team.organisers.should_not include follower
        end

        it 'follower remains follower' do
          team.followers.should include follower
        end

        it 'returns 401' do
          response.status.should eq(401)
        end
      end
    end

    context 'logged in team founder or organiser' do
      before :each do
        sign_in founder
        Team.stub(:find => team)
        team.stub(:is_public? => true)
      end

      # it 'adding a player should make the user a player in the team' do 
      #   do_create(team, new_user, PolyRole::PLAYER)
      #   team.players.should include new_user
      # end

      it 'adding a follower should make the user a follower in the team' do 
        do_create(team, new_user, PolyRole::FOLLOWER)
        team.followers.should include new_user
      end

      it 'should allow you to promote a follower to a player' do 
        do_create(team, follower, PolyRole::PLAYER)
        team.followers.should_not include follower
        team.players.should include follower
        team.organisers.should_not include follower
      end

      # it 'adding a parent should make the user a parent in the team' do 
      #   do_create(team, new_user, PolyRole::PARENT)
      #   team.parents.should include new_user
      # end

      it 'adding a organiser should make the user an organiser in the team' do 
        do_create(team, new_user, PolyRole::ORGANISER)
        team.organisers.should include new_user
        response.status.should eq(200)
      end

      it 'promoting a player to an a organiser should make the player an organiser in the team' do 
        do_create(team, player, PolyRole::ORGANISER)
        team.organisers.should include player
        response.status.should eq(200)
      end

      it 'returns 201 if successful' do
        do_create(team, new_user, PolyRole::FOLLOWER)
        response.status.should eq(200)
      end

      it 'returns 409 if confict occurs on duplicate create' do
        do_create(team, player, PolyRole::FOLLOWER)
        response.status.should eq(409)
      end

      it 'should increase the team role count by one' do
        expect { do_create(team, new_user, PolyRole::FOLLOWER) }.to change{PolyRole.count}.by(1)
      end
    end
  end
end
