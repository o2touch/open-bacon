require 'spec_helper'

describe Mitoo::MitooImporter do

  before :each do
    
  end

  context "#update_users" do

    before :each do
      @users = FactoryGirl.create_list(:mitoo_user, 5)

      Mitoo::MitooUser.stub(:find_all).and_return(@users)
    end

    it "creates new users" do
      expect{ Mitoo::MitooImporter.update_users }.to change{User.all.size}.by(@users.size)
    end

    it "creates gives users the invited role" do
      Mitoo::MitooImporter.update_users
      
      user = User.find_by_email(@users[0].email)
      user.invited_by_source.should == "MITOO"
      user.has_role?(RoleEnum::INVITED).should == true
    end

    it "doesn't create a user twice" do
      expect{ Mitoo::MitooImporter.update_users }.to change{User.all.size}.by(@users.size)
    end

    it "doesn't create a user if they are already in the system" do

      @existing_user = FactoryGirl.create(:user)
      @existing_user_fg = FactoryGirl.create(:mitoo_user, :email => @existing_user.email)

      @users = FactoryGirl.create_list(:mitoo_user, 5)
      @users << @existing_user_fg

      Mitoo::MitooUser.stub(:find_all_team_follows).and_return(@users)

      expect{ Mitoo::MitooImporter.update_users }.to change{User.all.size}.by(@users.size - 1)
     
    end    

  end

  context "#mitoo_importer" do

    before :each do
      @mitoo_team_follows = FactoryGirl.create_list(:mitoo_team_follows, 5)

      Mitoo::MitooTeamFollows.stub(:find_all_team_follows).and_return(@mitoo_team_follows)

    end

    context "when team does not exist" do
      before :each do
        @existing_user_fg = FactoryGirl.create(:mitoo_user)
        @mitoo_team_follows = FactoryGirl.create(:mitoo_team_follows, :mdb_teams_id => 12345)

        Mitoo::MitooUser.stub(:find).and_return(@existing_user_fg)
        Mitoo::MitooTeamFollows.stub(:find_all_team_follows).and_return([@mitoo_team_follows])
        Team.stub(:find_by_mitoo_id).and_return(nil)
      end

      it "does not error" do
        expect{ Mitoo::MitooImporter.update_team_follows }.to_not raise_error
      end

    end

  end

  context "#update_team_follows_for_user" do

    context "when team does not exist" do
      before :each do
        @mitoo_team_follows = FactoryGirl.create(:mitoo_team_follows, :mdb_teams_id => 12345)
        @user_id = 10
        @team_id = 11

        Team.should_receive(:find_by_mitoo_id).and_raise(ActiveRecord::RecordNotFound)
      end

      it "does raises an error" do
        expect{ Mitoo::MitooImporter.update_team_follows_for_user(@user_id, @team_id) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when user is not in goalrun import" do
      before :each do
        @mitoo_team_follows = FactoryGirl.create(:mitoo_team_follows, :mdb_teams_id => 12345)
        @team = FactoryGirl.create(:team)

        @user_id = 10
        @team_id = 12

        Team.should_receive(:find_by_mitoo_id).with(@team_id).and_return(@team)
        Mitoo::MitooUser.should_receive(:find).and_raise(Mitoo::RecordNotFound)
      end

      it "does raises an error" do
        expect{ Mitoo::MitooImporter.update_team_follows_for_user(@user_id, @team_id) }.to raise_error(Mitoo::RecordNotFound)
      end
    end

    context "when user is not in system" do
      before :each do
        @mitoo_team_follows = FactoryGirl.create(:mitoo_team_follows, :mdb_teams_id => 12345)
        @team = FactoryGirl.create(:team)
        @mitoo_user = FactoryGirl.create(:mitoo_user)

        @user_id = 10
        @team_id = 12

        Team.should_receive(:find_by_mitoo_id).with(@team_id).and_return(@team)
        Mitoo::MitooUser.should_receive(:find).with(@user_id).and_return(@mitoo_user)
        User.should_receive(:find_by_email!).with(@mitoo_user.email).and_raise(ActiveRecord::RecordNotFound)
      end

      it "does raises an error" do
        expect{ Mitoo::MitooImporter.update_team_follows_for_user(@user_id, @team_id) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when it should follow a team" do
      before :each do
        @mitoo_team_follows = FactoryGirl.create(:mitoo_team_follows, :mdb_teams_id => 12345)
        @team = FactoryGirl.create(:team)
        @mitoo_user = FactoryGirl.create(:mitoo_user)
        @user = FactoryGirl.create(:user)

        Team.should_receive(:find_by_mitoo_id).with(@team.id).and_return(@team)
        Mitoo::MitooUser.should_receive(:find).with(@user.id).and_return(@mitoo_user)
        User.should_receive(:find_by_email!).with(@mitoo_user.email).and_return(@user)

        TeamUsersService.should_receive(:add_follower).with(@team, @user).and_call_original
        AppEventService.should_not_receive(:create).with(@user, @user, "follower_invited", { team_id: @team.id })
        AppEventService.should_not_receive(:create).with(any_args())
      end

      it "does not raises an error" do
        expect{ Mitoo::MitooImporter.update_team_follows_for_user(@user.id, @team.id) }.to_not raise_error
      end

      it "adds user to team" do
        expect{ Mitoo::MitooImporter.update_team_follows_for_user(@user.id, @team.id) }.to change{ @team.followers.size }.by(1)
      end
    end

    context "when it should follow a team" do
      before :each do
        @mitoo_team_follows = FactoryGirl.create(:mitoo_team_follows, :mdb_teams_id => 12345)
        @team = FactoryGirl.create(:team)
        @mitoo_user = FactoryGirl.create(:mitoo_user)
        @user = FactoryGirl.create(:user)

        Team.should_receive(:find_by_mitoo_id).with(@team.id).and_return(@team)
        Mitoo::MitooUser.should_receive(:find).with(@user.id).and_return(@mitoo_user)
        User.should_receive(:find_by_email!).with(@mitoo_user.email).and_return(@user)

        AppEventService.should_not_receive(:create).with(@user, @user, "follower_invited", { team_id: @team.id })
        AppEventService.should_not_receive(:create).with(any_args())
      end

      it "adds user to team" do
        expect{ Mitoo::MitooImporter.update_team_follows_for_user(@user.id, @team.id) }.to change{ @team.followers.size }.by(1)
      end
    end
  end

  context "#send_initial_emails" do
    before :each do

      @team = FactoryGirl.create(:team)

      @user1 = FactoryGirl.create(:user)
      @user1.stub(:teams_as_follower).and_return([@team])

      @user2 = FactoryGirl.create(:user)

      @users = [@user1, @user2]

      Mitoo::MitooImporter.stub(:mitoo_users_app_event_triggered).and_return(@users)
    end
    it "adds user to team" do
      AppEventService.should_receive(:create).with(@user1, @user1, "user_imported", { team_id: @team.id })
      AppEventService.should_receive(:create).with(@user2, @user2, "user_imported", { })

      Mitoo::MitooImporter.send_initial_emails
    end
  end

  context "#mitoo_users_app_event_triggered" do
    before :each do
      @users = FactoryGirl.create_list(:user, 5, invited_by_source: "MITOO")

      user = @users[0]

      AppEventService.create(user, user, "user_imported", {})
    end

    it "returns the users not already sent an email" do
      users = Mitoo::MitooImporter.mitoo_users_app_event_triggered("user_imported", 10)

      users.size.should == (@users.size - 1)
    end
  end

end