require 'spec_helper'

describe UsersTeamsNotificationSetting do
  
  describe "#add_settings" do

    context "when setting already exists" do

      before :each do

        @user = FactoryGirl.create :user
        @team = FactoryGirl.create :team

        @setting1 = FactoryGirl.create :users_teams_notification_setting, user_id: @user.id, team_id: @team.id, notification_key: "stored_setting_1", value: false
      end

      it "does not create two values for same setting" do

        @settings = {
          @setting1.notification_key => @setting1.value
        }

        UsersTeamsNotificationSetting.add_settings(@user, @team, @settings)

        stored_settings = UsersTeamsNotificationSetting.where(user_id: @user.id, team_id: @team.id)
        stored_settings.size.should == 1
      end
    end

  end

  describe "#get_all_settings" do

    context "when user is follower" do
      it "returns all defaults for user" do
        pending
      end
    end

    context "when user is player" do

      context "with no stored settings" do

        before :each do

          @user = FactoryGirl.create :user
          @team = FactoryGirl.create :team

          UsersTeamsNotificationSetting.stub(:where).with({user_id: @user.id, team_id: @team.id}).and_return([])
        end

        it "returns all defaults for user" do
          settings = UsersTeamsNotificationSetting.get_all_settings(@user, @team)
          settings.size.should ==  NOTIFICATION_GROUP_DEFAULTS.size
        end
      end

      context "with stored notification setting" do
        before :each do

          @user = FactoryGirl.create :user
          @team = FactoryGirl.create :team
          @setting1 = FactoryGirl.create :users_teams_notification_setting, user_id: @user.id, team_id: @team.id, notification_key: "stored_setting_1", value: false
        end

        it "returns all defaults for user" do
          settings = UsersTeamsNotificationSetting.get_all_settings(@user, @team)
          settings.size.should == (NOTIFICATION_GROUP_DEFAULTS.size + 1)
        end
      end

      context "with stored group notification setting" do
        before :each do

          @user = FactoryGirl.create :user
          @team = FactoryGirl.create :team
          @setting1 = FactoryGirl.create :users_teams_notification_setting, user_id: @user.id, team_id: @team.id, notification_key: NotificationGroupsEnum::MESSAGING_AVAILABILITY, value: false
        end

        it "returns all defaults for user" do
          settings = UsersTeamsNotificationSetting.get_all_settings(@user, @team)

          settings.size.should == NOTIFICATION_GROUP_DEFAULTS.size

          settings_keys = settings.map { |s| s.notification_key }
          settings_keys.include?(NotificationGroupsEnum::MESSAGING_AVAILABILITY.to_s).should be_true

          settings.each do |s|
            s.value.should == false if s.notification_key == NotificationGroupsEnum::MESSAGING_AVAILABILITY
          end
        end
      end
    end

  end

end