require 'spec_helper'

describe Metrics::EngagementAnalysis do

  context "#summary" do

    before :each do
      @users = FactoryGirl.create_list(:user, 5)

      Metrics::EngagementAnalysis.stub(:all).and_return(@users)
    end

    it "works" do
      data = Metrics::EngagementAnalysis.summary(nil, :month, nil)

      data[:active_players].should == 1000
      data[:mobile_active].should == 1000
    end

  end

end