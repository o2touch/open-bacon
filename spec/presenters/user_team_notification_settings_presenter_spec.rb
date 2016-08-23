require 'spec_helper'

describe UserTeamNotificationSettingsPresenter do

	describe "#as_hash" do

		let(:setting_all_true) { FactoryGirl.create :users_teams_notification_setting, user_id: 2, team_id: 1234, notification_key: NotificationGroupsEnum::NOTIFICATIONS_ENABLED.to_s, value: true }
		let(:setting_all_false) { FactoryGirl.create :users_teams_notification_setting, user_id: 2, team_id: 1234, notification_key: NotificationGroupsEnum::NOTIFICATIONS_ENABLED.to_s, value: false }
		
		let(:setting1_true) { FactoryGirl.create :users_teams_notification_setting, user_id: 2, team_id: 1234, notification_key: "stored_setting_1", value: true }
		let(:setting1_false) { FactoryGirl.create :users_teams_notification_setting, user_id: 2, team_id: 1234, notification_key: "stored_setting_1", value: false }
		
		let(:setting2_true) { FactoryGirl.create :users_teams_notification_setting, user_id: 2, team_id: 1234, notification_key: "stored_setting_2", value: true }
		let(:setting2_false) { FactoryGirl.create :users_teams_notification_setting, user_id: 2, team_id: 1234, notification_key: "stored_setting_2", value: false }

		context "when NOTIFICATIONS_ENABLED key is true" do
			it "overwrites all settings as false" do
				hash = UserTeamNotificationSettingsPresenter.new([setting_all_true, setting1_true, setting2_true]).as_hash

				hash.size.should == 3
				hash["stored_setting_1"].should == true
				hash["stored_setting_2"].should == true
			end
		end

		context "when NOTIFICATIONS_ENABLED key is false" do
			it "overwrites all settings as false" do
				hash = UserTeamNotificationSettingsPresenter.new([setting_all_false, setting1_true, setting2_true]).as_hash

				hash.size.should == 3
				hash["stored_setting_1"].should == false
				hash["stored_setting_2"].should == false
			end
		end

	end

end