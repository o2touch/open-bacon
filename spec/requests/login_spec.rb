require 'spec_helper'

describe "as a guest on the homepage", :js => true do
  
  self.use_transactional_fixtures = false # We need this because Capybara visit method breaks the transaction

  before :each do    
    @user = FactoryGirl.create(:user)
    visit root_path
    find('.login-link').click
  end

  context "with valid credentials" do
    
    before do
      within(".login-form") do
        fill_in 'login-email', :with => @user.email
        fill_in 'login-password', :with => "password"
        find("button[type='submit']").click
      end 
    end

    # it "has sign out link" do
    #   page.should have_xpath("//a", :text => "Sign Out") 
    # end

    it "knows who I am" do
      page.should have_content(@user.name)
    end

  end

  context "with invalid credentials" do

    before do
      within(".login-form") do
        fill_in 'login-email', :with => @user.email
        fill_in 'login-password', :with => "incorrect"
        find("button[type='submit']").click
      end 
    end

    it "displays an error" do
      page.should have_content("Your username/password is incorrect")
    end

  end

end 