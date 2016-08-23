require 'spec_helper'

describe UserProfile do

  context 'user profile factory' do
    it "is valid" do
      user_profile = FactoryGirl.create(:user_profile)
      user_profile.should be_valid
    end
  end

  context 'bio' do
    it 'validates the presence of the bio' do
      FactoryGirl.build(:user_profile, :bio => nil).valid?.should be_true
    end

    it 'validates the miniumum length of the bio' do
      FactoryGirl.build(:user_profile, :bio => "").valid?.should be_true
      FactoryGirl.build(:user_profile, :bio => "x").valid?.should be_true
    end

    it 'validates the maximum length of the bio' do
      FactoryGirl.build(:user_profile, :bio => "x"*UserProfile::MINIMUM_BIO_LENGTH).valid?.should be_true
      FactoryGirl.build(:user_profile, :bio => "x"*(UserProfile::MAXIMUM_BIO_LENGTH+1)).valid?.should be_false
    end
  end
end