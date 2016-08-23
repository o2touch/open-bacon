require 'spec_helper'

describe Api::V1::Users::UserRegistrationsController do

  before :each do
    # This stubs out the before_filter of application_controller
    Api::V1::Users::UserRegistrationsController.any_instance.stub(:log_user_activity)
  end

	describe '#create' do

    context 'no save_type is supplied' do
      it 'returns uprocessable' do
        post :create, user: @attrs, format: :json
        response.status.should eq(422)
      end
    end

    context "normal user" do

  		def do_create(attrs=nil)
  			@attrs = {
  				name: "Timothy Sherratt",
  				email: "tpsherratt@googlemail.com",
  				mobile_number: "07793966182",
  				password: "password",
  			}

  			post :create, user: @attrs, save_type: "NORMAL", format: :json
  		end

  		context 'when user is signed in' do
  			it 'uses the signed in user' do
  				@user = FactoryGirl.build :user
  				signed_in(@user)
  				User.should_not_receive(:create!)
  				UserRegistrationsService.should_receive(:complete_registration).with(@user, "NORMAL", kind_of(Hash))
  				controller.should_receive(:sign_in).with(@user, bypass: true) # as they get logged out when changing password
  				controller.should_not_receive :save_utm_data
  				do_create
  				response.status.should eq(200)
  			end
  		end

# corresponding code is commented, but left in as will be required in due course
=begin
		context 'user is signed out, but in db' do
			it 'users the user in the db' do
				signed_out
				@user = double("user")
				User.stub!(find_by_email: @user)
				User.should_not_receive(:create!)
				UserRegistrationsService.should_receive(:complete_registration).with(@user, "NORMAL", kind_of(Hash))
				controller.should_receive(:sign_in).with(@user)
				controller.should_not_receive :save_utm_data
				do_create
				response.status.should eq(200)
			end
		end
=end

  		context 'user is new' do
  			it 'creates a user using the attrs' do
  				signed_out
  				UserRegistrationsService.should_receive(:complete_registration).with(kind_of(User), "NORMAL", kind_of(Hash))
  				controller.should_receive(:sign_in).with(kind_of(User), bypass: true)
  				controller.should_receive(:save_utm_data).with(kind_of(User))
  				lambda { do_create }.should change(User, :count).by(1)
  				response.status.should eq(200)
  			end
  		end

      context 'existing users' do
        context 'invited user' do
          it 'sets them as registered, and logs them in' do
            signed_out
            @user = FactoryGirl.create :user
            @user.add_role(RoleEnum::INVITED)
            User.should_receive(:find_by_email).and_return(@user)

            UserRegistrationsService.should_receive(:complete_registration).with(@user, "NORMAL", kind_of(Hash))
            controller.should_receive(:sign_in).with(@user, bypass: true)
            controller.should_receive(:save_utm_data).with(@user)
            lambda { do_create }.should change(User, :count).by(0)
            response.status.should eq(200)
          end
        end
        context 'registered user' do
          it 'tells them to fuck off' do
            signed_out
            @user = FactoryGirl.create :user
            @user.add_role(RoleEnum::REGISTERED)
            User.should_receive(:find_by_email).and_return(@user)

            UserRegistrationsService.should_not_receive(:complete_registration).with(@user, "NORMAL", kind_of(Hash))
            controller.should_not_receive(:sign_in).with(@user, bypass: true)
            controller.should_not_receive(:save_utm_data).with(@user)
            lambda { do_create }.should change(User, :count).by(0)
            response.status.should eq(422)
          end
        end
      end
    end

    context "user claiming league" do
      def do_create(attrs=nil)
        @attrs = {
          name: "Timothy Sherratt",
          email: "tpsherratt@googlemail.com",
          mobile_number: "07793966182",
          password: "password",
        }

        post :create, user: @attrs, save_type: "USERCLAIMLEAGUE", format: :json
      end

      context 'user is new' do
        it 'creates a user using the attrs' do
          signed_out
          UserRegistrationsService.should_receive(:complete_registration).with(kind_of(User), "USERCLAIMLEAGUE", kind_of(Hash))
          controller.should_receive(:sign_in).with(kind_of(User), bypass: true)
          controller.should_receive(:save_utm_data).with(kind_of(User))
          lambda { do_create }.should change(User, :count).by(1)
          response.status.should eq(200)
        end
      end
    end
	end

  def mock_team
    mock = double("team")
    mock.stub(goals:GoalChecklist.new)
    mock
  end


	# old tests
  describe '#create' do
    

  	before :each do
    	@team = mock_team
    	@team.stub!(:add_organiser)
      @team.stub!(:created_by_id=)
      @team.stub!(:created_by_type=)
      TeamUsersService.stub(:add_organiser)
    	Team.stub!(find_by_uuid: @team)
  		auth = double("auth")
			auth.stub!(authorize!: true)
			Ability.stub!(new: auth)
	  end

    context 'player via team open invite link' do
      before :each do
        @token = double("token")
        @token.stub!(token_matches?: true)
        PowerToken.stub!(find_active_token: @token)
      end

      context 'valid information' do
        before :each do
          @user = FactoryGirl.create(:user, :with_team_events)
          @team = @user.teams_as_organiser.first
          @team_count = Team.count
          email = "test@bluefields.com"
          request_params = FactoryGirl.attributes_for(:user, :email => email, :time_zone => "Africa/Lagos")
          
          open_invite_link = @team.open_invite_link
          token = PowerToken.find(1)

          post :create, :save_type => UserInvitationTypeEnum::TEAM_OPEN_INVITE_LINK, :team_id => @team.id, :token => token.token, :user => request_params, :format => :json

          @new_user = User.find_by_email(email)
        end

        it 'creates the user' do
          @new_user.should_not be_nil
          @new_user.should be_valid
        end

        it 'does not create a new team' do
          Team.count.should == @team_count
        end

        it 'adds the user to the team' do
          @team.players.should include @new_user
        end

        it 'logs the invitation type against the user' do
          @new_user.invited_by_source.should eql UserInvitationTypeEnum::TEAM_OPEN_INVITE_LINK
        end

        it 'sets the timezone based on the team founders timezone' do
          @new_user.time_zone.should == @team.founder.time_zone
        end

        it 'returns success' do
          response.header['Content-Type'].should include 'json'
          response.status.should == HTTPResponseCodeEnum::OK
        end
      end

      context 'unknown token' do
        before :each do
          @token.stub!(token_matches?: false)
          @user = FactoryGirl.create(:user, :with_team_events)
          @team = @user.teams_as_organiser.first
          @team_count = Team.count
          email = "test@bluefields.com"
          request_params = FactoryGirl.attributes_for(:user, :email => email, :time_zone => "Africa/Lagos")
          
          open_invite_link = @team.open_invite_link
          token = "unknown"

          post :create, :save_type => UserInvitationTypeEnum::TEAM_OPEN_INVITE_LINK, :team_id => @team.id, :token => token, :user => request_params, :format => :json

          @new_user = User.find_by_email(email)
        end

        it 'does not create a new user' do
          @new_user.should be_nil
        end

        it 'returns an error' do
          response.header['Content-Type'].should include 'json'
          response.status.should == 422
        end
      end

      context 'unknown team' do
        before :each do
          @token.stub!(token_matches?: false)
          @user = FactoryGirl.create(:user, :with_team_events)
          @team = @user.teams_as_organiser.first
          @team_count = Team.count
          email = "test@bluefields.com"
          request_params = FactoryGirl.attributes_for(:user, :email => email, :time_zone => "Africa/Lagos")
          
          open_invite_link = @team.open_invite_link
          token = PowerToken.find(1)

          post :create, :save_type => UserInvitationTypeEnum::TEAM_OPEN_INVITE_LINK, :team_id => 5000, :token => token.token, :user => request_params, :format => :json

          @new_user = User.find_by_email(email)
        end

        it 'does not create a new user' do
          @new_user.should be_nil
        end

        it 'returns an error' do
          response.header['Content-Type'].should include 'json'
          response.status.should == 404
        end
      end
    end
    
    describe 'logged out signing up from the homepage' do

      context 'specifying valid credentials' do
      
        before :each do
          @user = FactoryGirl.create(:user)

          email = "test@bluefields.com"
          request_params = FactoryGirl.attributes_for(:user, :email => "test@bluefields.com") 
          post :create, :save_type => UserInvitationTypeEnum::NORMAL, :user => request_params, :format => 'html'

          @new_user = User.find_by_email(email)
        end

        it 'creates the user' do
          @new_user.should_not be_nil
          @new_user.should be_valid
        end

        it 'logs the invitation type against the user' do
          @new_user.invited_by_source.should eql UserInvitationTypeEnum::NORMAL
        end
      end

      context 'specifying valid credentials via :user' do

        before :each do
          @user = FactoryGirl.create(:user)

          email = "test@bluefields.com"
          request_params = FactoryGirl.attributes_for(:user, :email => "test@bluefields.com") 
          post :create, :save_type => UserInvitationTypeEnum::NORMAL, :user => request_params, :format => 'html'

          @new_user = User.find_by_email(email)
        end

        it 'creates the user' do
          @new_user.should_not be_nil
          @new_user.should be_valid
        end

        it 'logs the invitation type against the user' do
          @new_user.invited_by_source.should eql UserInvitationTypeEnum::NORMAL
        end
      end
      context 'specifying an existing login email address' do
        before :each do
          @user = FactoryGirl.create(:user)
          @user_count = User.count
          request_params = FactoryGirl.attributes_for(:user, :email => @user.email)
          request.env['HTTP_REFERER'] = "where_i_came_from"

          post :create, :save_type => UserInvitationTypeEnum::NORMAL, :user => request_params, :format => 'html'
        end

        it 'redirects back' do
        	response.status.should eq(422)
        end
      end
    end

    context 'invalid invitation type specified' do
      
      before :each do
        @email = "test@bluefields.com"
        request_params = FactoryGirl.attributes_for(:user, :email => @email ) 

        post :create, :save_type => "MUNDIYAN-TU-BACH-KE", :user => request_params, :format => 'html'
      end

      it 'doesnt create the user' do
        User.find_by_email(@email).should be_nil
      end

      it 'returns an error' do
        response.code.to_i.should == 422
      end
    end

    describe 'logged out signing up from /signup' do

      describe 'specifying invalid credentials' do

        before :each do
          @user = FactoryGirl.create(:user)
          @user_count = User.count
          @user_for_request_params = FactoryGirl.attributes_for(:user, :email => @user.email)
        end

        context 'via HTML request' do
          before :each do
            request.env['HTTP_REFERER'] = "where_i_came_from"
            post :create, :save_type => UserInvitationTypeEnum::NORMAL, :user => @user_for_request_params, :format => 'html'
          end

          it 'doesnt create the user' do
            User.count.should == @user_count
          end
        end

        context 'via JSON' do
          before :each do
            post :create, :save_type => UserInvitationTypeEnum::NORMAL, :user => @user_for_request_params, :format => 'json'
          end

          it 'doesnt create the user' do
            User.count.should == @user_count
          end

          it 'response status is UNPROCESSABLE_ENTITY' do
            response.code.to_i.should == HTTPResponseCodeEnum::UNPROCESSABLE_ENTITY
          end

          it 'response is JSON' do
            response.header['Content-Type'].should include 'json'
          end
        end
      end
    end

    describe 'specifying no time zone fails' do

      before :each do
        @user = FactoryGirl.create(:user)
        @user_count = User.count
        @user_for_request_params = FactoryGirl.attributes_for(:user, :email => @user.email, :time_zone => nil)
      end

      describe 'specifying not time zone reads from cookies' do
        context 'via JSON' do
          before :each do
            email = "test@bluefields.com"
            request_params = FactoryGirl.attributes_for(:user, :email => "test@bluefields.com", :time_zone => nil) 
            request.cookies['timezone'] = "America/New_York"
            request.env['HTTP_REFERER'] = "where_i_came_from"
            post :create, :save_type => UserInvitationTypeEnum::NORMAL, :user => request_params, :format => 'json'
            @new_user = User.find_by_email(email)
          end
          
          it 'creates the user' do
            @new_user.should_not be_nil
            @new_user.should be_valid
          end

          it 'logs the invitation type against the user' do
            @new_user.invited_by_source.should eql UserInvitationTypeEnum::NORMAL
          end
          it 'sets the correct time zone' do
            @new_user.time_zone.should == "America/New_York"
          end

          it 'returns success' do
            response.header['Content-Type'].should include 'json'
            response.status.should == HTTPResponseCodeEnum::OK
          end
        end
      end
    end
  end
end

