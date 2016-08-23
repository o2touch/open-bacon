require 'spec_helper'

describe TeamProfile do

  context 'team profile factory' do
    it "is valid" do
      team_profile = FactoryGirl.create(:team_profile)
      team_profile.should be_valid
    end
  end
end