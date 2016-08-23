require 'spec_helper'

describe NotificationReceipt do

  context 'notification receipt factory' do
    it "is valid" do
      organiser = FactoryGirl.create(:user, :with_teams, :team_count => 1)
      team = organiser.teams_as_organiser.first
      ni = FactoryGirl.build(:notification_item, :subj => organiser, :obj => team, :verb => :created)
      en = FactoryGirl.build(:email_notification, :notification_item => ni)
      en.sender.should be_valid
      en.notification_item.should be_valid

      nr = FactoryGirl.create(:notification_receipt, :notification => en)
      nr.should be_valid
    end
  end
end
