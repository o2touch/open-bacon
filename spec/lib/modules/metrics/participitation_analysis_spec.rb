require 'spec_helper'

describe Metrics::ParticipationAnalysis do

  context "#all" do

    before :each do
      @users = FactoryGirl.create_list(:user, 5)
    end

    it "works" do
      data = Metrics::ParticipationAnalysis.all(nil, :month, nil)

      data.size.should >= 0
    end

  end

  context "#by_gender" do

    def build_user_with_profile(profile)
      u = FactoryGirl.build(:user)
      u.stub(:profile).and_return(profile)
      u
    end

    before :each do
      @male_profile = double(UserProfile)
      @male_profile.stub(:gender).and_return("m")

      @female_profile = double(UserProfile)
      @female_profile.stub(:gender).and_return("f")

      @unset_profile = double(UserProfile)
      @unset_profile.stub(:gender).and_return("")

      @users = []
      @users << build_user_with_profile(@male_profile)
      @users << build_user_with_profile(@male_profile)
      @users << build_user_with_profile(@male_profile)
      @users << build_user_with_profile(@female_profile)
      @users << build_user_with_profile(@female_profile)
      @users << build_user_with_profile(@unset_profile)

      Metrics::ParticipationAnalysis.stub(:all).and_return(@user_ids)
      Metrics::ParticipationAnalysis.stub(:get_users_from_ids).and_return(@users)
    end

    it "works" do
      data = Metrics::ParticipationAnalysis.by_gender(nil, :month, nil)

      data[:male].should == 3
      data[:female].should == 2
      data[:unset].should == 1
    end

  end

  context "#by_experience" do

    def build_user_with_experience(experience)
      u = FactoryGirl.build(:user)
      u.stub(:tenanted_attrs).and_return({
        player_history: experience
      })
      u
    end

    before :each do
      @users = []
      @users << build_user_with_experience("new")
      @users << build_user_with_experience("new")
      @users << build_user_with_experience("new")
      @users << build_user_with_experience("existing")
      @users << build_user_with_experience("existing")
      @users << build_user_with_experience("unset")

      Metrics::ParticipationAnalysis.stub(:all).and_return(@user_ids)
      Metrics::ParticipationAnalysis.stub(:get_users_from_ids).and_return(@users)
    end

    it "works" do
      data = Metrics::ParticipationAnalysis.by_experience(nil, :month, nil)

      data[:new_to_rugby].should == 3
      data[:existing].should == 2
      data[:unset].should == 1
    end

  end

  context "#by_source" do

    def build_user_with_source(source)
      u = FactoryGirl.build(:user)
      u.stub(:invited_by_source).and_return(source)
      u
    end

    before :each do
            @users = []
      @users << build_user_with_source("EVENT")
      @users << build_user_with_source("EVENT")
      @users << build_user_with_source("EVENT")
      @users << build_user_with_source("TEAMPROFILE")
      @users << build_user_with_source("TEAMPROFILE")
      @users << build_user_with_source("unset")

      Metrics::ParticipationAnalysis.stub(:all).and_return(@user_ids)
      Metrics::ParticipationAnalysis.stub(:get_users_from_ids).and_return(@users)
    end

    it "works" do
      data = Metrics::ParticipationAnalysis.by_source(nil, :month, nil)

      data[:web].should == 3
      data[:operator].should == 2
      data[:unset].should == 1
    end

  end

  context "#by_frequency" do

    before :each do
      @tenant = Tenant.find(2)

      # This is how the MitooMetrics gem returns the data
      @data = [
        [100, 1],
        [101, 1],
        [102, 1],
        [103, 2],
        [104, 2],
        [105, 3],
        [106, 4],
        [107, 4]
      ]

      MitooMetrics::Tools.stub(:execute_cached_query).and_return(@data)
    end

    it "works" do
      data = Metrics::ParticipationAnalysis.by_frequency(@tenant.id, :month, Date.today)

      data[0][:once].should == 3
      data[0][:twice].should == 2
      data[0][:thrice].should == 3
    end

  end

end