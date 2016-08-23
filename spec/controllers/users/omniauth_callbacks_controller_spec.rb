require 'spec_helper'

describe Users::OmniauthCallbacksController, :type => :controller do
  
  describe "Facebook provider" do

    before do
      request.env["devise.mapping"] = Devise.mappings[:user]
      request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:facebook]
      request.env["omniauth.params"] = {}
      UserRegistrationsService.stub!(:complete_registration)
    end

    it "sets a session variable to the OmniAuth auth hash" do
      request.env["omniauth.auth"][:uid].should == '1234567'
    end

    context "when a new user signs-up through FB" do

      before :each do
        request.env["omniauth.params"]['save_type'] = "NORMAL"
        @usercount = User.count

        get :facebook
      end

      it "registers the user" do
        User.count.should == @usercount + 1
      end

      it "associates the facebook account details" do

        fbUserEmail = request.env["omniauth.auth"][:info][:email]
        user = User.find_by_email(fbUserEmail)

        authFB = Authorization.find_by_user_id(user.id)
        
        authFB.should_not be_nil
        authFB.uid.should == request.env["omniauth.auth"][:uid]
      end

      it 'sets the users timezone in string (Continent/City) format' do
        fbUserEmail = request.env["omniauth.auth"][:info][:email]
        user = User.find_by_email(fbUserEmail)
        user.time_zone.is_a? String
      end
    end

    context "when an existing user connects FB" do

      login_organiser

      before :each do
        @team = FactoryGirl.create(:team, :with_events, event_count: 1)
        @event = @team.events.first
        TeamsheetEntry.any_instance.stub :push_create_to_feeds
        EventInvitesService.add_players(@event, [subject.current_user])

        @usercount = User.count
        @authcount = Authorization.count
        @originalemail = subject.current_user.email
        get :facebook
      end

      it "does not create a new user" do
        User.count.should == @usercount
      end 

      it "creates a new Authorization" do
        Authorization.count.should == @authcount + 1
      end

      it "associates the facebook account details" do

        authFB = Authorization.find_by_user_id(subject.current_user.id)
        
        authFB.should_not be_nil
        authFB.uid.should == request.env["omniauth.auth"][:uid]
      end

      it "does not change the user email" do
        subject.current_user.email.should == @originalemail
      end

      it 'does not make them owner of all events they are invited to (bug)' do
        @event.reload
        @event.user_id.should_not eq(subject.current_user.id)
      end
    end

    context "when an existing user connects FB account already associated to another user" do

      login_organiser

      before :each do
        
        @existingUser = FactoryGirl.create(:user, :with_fb_connected)
        
        @usercount = User.count
        @authcount = Authorization.count

        get :facebook
      end

      it "does not create a new user" do
        User.count.should == @usercount
      end 

      it "does not create a new Authorization" do
        Authorization.count.should == @authcount
      end

    end

    context "when an existing user logins through FB account" do

      before :each do
        
        @existingUser = FactoryGirl.create(:user, :with_fb_connected)
        as_user(@existingUser) do
          @usercount = User.count
          @authcount = Authorization.count

          get :facebook
        end
      end

      it "does not create a new user" do
        User.count.should == @usercount
      end 

      it "does not create a new Authorization" do
        Authorization.count.should == @authcount
      end

      it "logs user in" do
        warden.authenticated?(:user).should == true
      end
    end
  end
end