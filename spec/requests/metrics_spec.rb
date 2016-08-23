require 'spec_helper'

describe "as a guest on the homepage", :js => true do
  
  self.use_transactional_fixtures = false # We need this because Capybara visit method breaks the transaction

  before :each do
    @user_attr = FactoryGirl.attributes_for(:user)
    @user = User.create(@user_attr)
    @user.save
  end

  before do
    visit root_path
    click_link 'btn-show-login'
  end

  # context "with valid credentials", :redis => true do
    
  #   before do

  #     @dau_original = Metrics::getDailyActiveUsers()

  #     within("#login") do
  #       fill_in 'Email', :with => @user.email
  #       fill_in 'Password', :with => "password"
  #       click_button 'Log In'
  #     end
  #   end

  #   it "DAU metrics reflect this" do
  #     Metrics::getDailyActiveUsers().should == @dau_original + 1
  #   end

  # end

end 