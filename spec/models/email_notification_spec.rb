require 'spec_helper'

describe EmailNotification do

  context 'email notification factory' do
    it "is valid" do
      organiser = FactoryGirl.create(:user, :with_teams, :team_count => 1)
      team = organiser.teams_as_organiser.first
      ni = FactoryGirl.build(:notification_item, :subj => organiser, :obj => team, :verb => :created)
      en = FactoryGirl.create(:email_notification, :sender => organiser, :notification_item => ni)
      en.sender.should be_valid
      en.notification_item.should be_valid
    end
  end
end
