require 'spec_helper'

describe UserTeamNotificationPolicy do

  describe "#initialize" do

    it "initialzes" do
      user = FactoryGirl.create :user
      team = FactoryGirl.create :team

      utns = []
      utns << FactoryGirl.create(:users_teams_notification_setting, user_id: user.id, team_id: team.id, notification_key: "key_1", value: true)
      utns << FactoryGirl.create(:users_teams_notification_setting, user_id: user.id, team_id: team.id, notification_key: "key_2", value: true)
      utns << FactoryGirl.create(:users_teams_notification_setting, user_id: user.id, team_id: team.id, notification_key: "key_3", value: true)

      UsersTeamsNotificationSetting.should_receive(:where).with({user_id: user.id, team_id: team.id}).and_call_original

      unp = UserTeamNotificationPolicy.new(user, team)
    end

  end

  describe "#should_notify?" do

    let(:user) { FactoryGirl.create :user }
    let(:team) { FactoryGirl.create :team }
  
    context "when all is set to false" do
      it "is returns false" do

        UserTeamNotificationPolicy.any_instance.stub(:load_settings).and_return({
          NotificationGroupsEnum::NOTIFICATIONS_ENABLED => false
        })

        unp = UserTeamNotificationPolicy.new(user, team)

        unp.should_notify?("team_message_created").should == false
      end
    end

    context "when a notification key is set" do
      it "returns true" do

        UserTeamNotificationPolicy.any_instance.stub(:load_settings).and_return({
          NotificationGroupsEnum::NOTIFICATIONS_ENABLED => true,
          "team_message_created" => true
        })

        unp = UserTeamNotificationPolicy.new(user, team)

        unp.should_notify?("team_message_created").should == true
      end

      it "returns false" do

        UserTeamNotificationPolicy.any_instance.stub(:load_settings).and_return({
          NotificationGroupsEnum::NOTIFICATIONS_ENABLED => true,
          :team_message_created => false
        })

        unp = UserTeamNotificationPolicy.new(user, team)

        unp.should_not_receive(:get_group_for_notification)
        unp.should_notify?("team_message_created").should == false
      end
    end

    context "when a group key is set" do
      it "returns true" do

        UserTeamNotificationPolicy.any_instance.stub(:load_settings).and_return({
          NotificationGroupsEnum::MESSAGING_AVAILABILITY => true
        })

        unp = UserTeamNotificationPolicy.new(user, team)

        unp.should_notify?("team_message_created").should == true
      end

      it "returns false" do

        UserTeamNotificationPolicy.any_instance.stub(:load_settings).and_return({
          NotificationGroupsEnum::MESSAGING_AVAILABILITY => false
        })

        unp = UserTeamNotificationPolicy.new(user, team)

        n_key = "team_message_created"

        unp.should_receive(:get_group_for_notification).with(n_key).and_call_original
        unp.should_notify?(n_key).should == false
      end
    end

    context "when a group key is set with all" do
      it "returns true" do

        UserTeamNotificationPolicy.any_instance.stub(:load_settings).and_return({
          NotificationGroupsEnum::NOTIFICATIONS_ENABLED => true,
          NotificationGroupsEnum::MESSAGING_AVAILABILITY => true
        })

        unp = UserTeamNotificationPolicy.new(user, team)

        unp.should_notify?("team_message_created").should == true
      end

      it "returns false" do

        UserTeamNotificationPolicy.any_instance.stub(:load_settings).and_return({
          NotificationGroupsEnum::NOTIFICATIONS_ENABLED => true,
          NotificationGroupsEnum::MESSAGING_AVAILABILITY => false
        })

        unp = UserTeamNotificationPolicy.new(user, team)

        n_key = "team_message_created"

        unp.should_receive(:get_group_for_notification).with(n_key).and_call_original
        unp.should_notify?(n_key).should == false
      end
    end

    context "when key does not exist" do
      it "returns true" do

        UserTeamNotificationPolicy.any_instance.stub(:load_settings).and_return({
          NotificationGroupsEnum::NOTIFICATIONS_ENABLED => true,
          NotificationGroupsEnum::MESSAGING_AVAILABILITY => true
        })

        unp = UserTeamNotificationPolicy.new(user, team)

        unp.should_notify?("message_updated").should == true
      end
    end

    context "when key does not have a setting but it has a default" do
      it "returns true" do

        NOTIFICATION_GROUP_DEFAULTS[NotificationGroupsEnum::TEAM_GAMES] = false

        unp = UserTeamNotificationPolicy.new(user, team)

        unp.should_notify?("event_created").should == false
      end
    end
  end

end