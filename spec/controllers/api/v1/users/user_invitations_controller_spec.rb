require 'spec_helper'

describe Api::V1::Users::UserInvitationsController do

  before :each do
    # This stubs out the before_filter of application_controller
    Api::V1::Users::UserInvitationsController.any_instance.stub(:log_user_activity)
  end

	describe '#create' do
		before :each do
			@user_attrs = {
				name: "Timothy Sherratt",
				parent_name: "Paul Sherratt",
				email: "tpsherratt@googlemail.com",
				mobile_number: "+447793966182",
			}
			@team_id = 1
			@save_type = ""
      AppEventService.stub(:create)
		end

		def do_create(save_type="TEAMPROFILE", user_has_type=:email)

      @user_attrs.delete(:email) if user_has_type==:mobile_number

			post :create, user: @user_attrs, team_id: @team_id, save_type: save_type
		end

    def mock_team
      mock = FactoryGirl.create :team
      mock.stub(faft_id: nil)
      mock.stub(goals:GoalChecklist.new)
      mock
    end

		context 'errors' do
			before :each do
				fake_ability
				signed_in FactoryGirl.create :user
			end

			it 'should return 404 if no team' do
				post :create, user: @user_attrs
				response.status.should eq(404)
			end
			it 'should return 422 if no user attrs' do
				Team.stub!(:find).and_return(mock_team)
				post :create, team_id: @team_id
				response.status.should eq(422)
			end
			it 'should return 433 if an email address and mobile number are not supplied' do
				@user_attrs[:email] = nil
        @user_attrs[:mobile_number] = nil
				Team.stub!(:find).and_return(mock_team)
				post :create, user: @user_attrs, team_id: @team_id
				response.status.should eq(422)
			end
		end

		context 'authorization checking' do
			it 'should check :manage perm on team', :sidekiq => false do
				signed_in FactoryGirl.create :user
				mock_ability manage_roster: true
				Team.stub!(:find).and_return(mock_team)
				do_create
			end

			it 'should required the user to be signed in' do
				fake_ability
				Team.stub!(:find).and_return(mock_team)
				do_create
				response.status.should eq(401)
			end
		end

		context 'success' do
			before :each do
				fake_ability
				@signed_in_user = FactoryGirl.build :user, id: 10
				signed_in(@signed_in_user)
				@team = mock_team
				Team.stub!(:find).and_return(@team)
			end

			context 'inviting an adult' do 
				context 'user already registered' do
					it 'should add that user to the team and shit' do
						@user = double("user")
						User.should_receive(:find_by_email).with(@user_attrs[:email]).and_return(@user)
						User.should_not_receive(:create!)
						TeamUsersService.should_receive(:add_player).once.with(@team, @user, true, @signed_in_user)

						do_create

						response.status.should eq(200)
					end
				end

				context 'user not registered yet' do
					it 'should create a new user and add them' do
						TeamUsersService.should_receive(:add_player).once.with(@team, kind_of(User), true, @signed_in_user)
						@signed_in_user.should_receive(:time_zone).and_return(0)

						lambda{ do_create }.should change(User, :count).by(1)

						response.status.should eq(200)
						User.last.role?(RoleEnum::INVITED).should eq(true)
						User.last.role?(RoleEnum::REGISTERED).should eq(false)
					end
				end
			end

      context 'inviting an adult follower' do 

        context 'by email' do
          context 'user already registered' do
            it 'should add that user to the team and shit' do
              @user = FactoryGirl.create :user
              User.should_receive(:find_by_email).with(@user_attrs[:email]).and_return(@user)
              User.should_not_receive(:create!)
              TeamUsersService.should_receive(:add_follower).once.with(@team, @user, @signed_in_user)

              do_create UserInvitationTypeEnum::TEAM_FOLLOW

              response.status.should eq(200)
            end
          end

          context 'user not registered yet' do
            it 'should create a new user and add them' do
              TeamUsersService.should_receive(:add_follower).once.with(@team, kind_of(User), @signed_in_user)
              @signed_in_user.should_receive(:time_zone).and_return(0)

              lambda{ do_create(UserInvitationTypeEnum::TEAM_FOLLOW) }.should change(User, :count).by(1)

              response.status.should eq(200)
              User.last.role?(RoleEnum::INVITED).should eq(true)
              User.last.role?(RoleEnum::REGISTERED).should eq(false)
            end
          end
        end
      

        context 'by mobile number' do 
          context 'user already registered' do
            it 'should add that user to the team and shit' do
              @user = FactoryGirl.create :user
              User.should_receive(:find_by_mobile_number).with(@user_attrs[:mobile_number]).and_return(@user)
              User.should_not_receive(:create!)
              TeamUsersService.should_receive(:add_follower).once.with(@team, @user, @signed_in_user)

              do_create UserInvitationTypeEnum::TEAM_FOLLOW, :mobile_number

              response.status.should eq(200)
            end
          end

          context 'user already registered and associate of the team' do
            it 'should add that user to the team and shit' do
              @user = FactoryGirl.create :user
              User.should_receive(:find_by_mobile_number).with(@user_attrs[:mobile_number]).and_return(@user)
              User.should_not_receive(:create!)
              TeamUsersService.should_receive(:add_follower).once.with(@team, @user, @signed_in_user).and_raise(InviteToTeamError)

              do_create UserInvitationTypeEnum::TEAM_FOLLOW, :mobile_number
              response.status.should eq(422)
            end
          end

          context 'user not registered yet' do
            it 'should create a new user and add them' do
              TeamUsersService.should_receive(:add_follower).once.with(@team, kind_of(User), @signed_in_user)
              @signed_in_user.should_receive(:time_zone).and_return(0)

              lambda{ do_create(UserInvitationTypeEnum::TEAM_FOLLOW, :mobile_number) }.should change(User, :count).by(1)

              response.status.should eq(200)
              User.last.role?(RoleEnum::INVITED).should eq(true)
              User.last.role?(RoleEnum::REGISTERED).should eq(false)
            end
          end
        end
      end

      context 'creating a user, and checking them in' do
        before :each do
          @event = FactoryGirl.create :event
          @event.team = @team
          @event.save

          @params = {
            name: "HIIIIII",
            email: 'wu@fu.om',
            mobile_number: "+440000000"
          }
        end

        def event_checkin_shit
          post :create, user: @params, team_id: @team.id, event_id: @event.id, save_type: UserInvitationTypeEnum::EVENT_CHECKIN
        end
        it 'should return 200, innit' do
          event_checkin_shit
          response.status.should eq(200)
        end

        it 'should add the fucker to the team' do
          TeamUsersService.should_receive(:add_player).once.with(@team, kind_of(User), true, @signed_in_user, false).and_call_original
          event_checkin_shit
        end
        it 'should synchronously add them to the event' do
          EventInvitesService.should_receive(:add_players).twice.and_call_original
          event_checkin_shit
        end
        it 'should check them in' do
          TeamsheetEntriesService.should_receive(:check_in).and_call_original
          event_checkin_shit
        end
      end

      context 'inviting a second parent for given child' do
        before :each do
          @junior = FactoryGirl.create(:junior_user)
          @first_parent = @junior.parents.first

          @team.profile.age_group = AgeGroupEnum::UNDER_10
          @team.profile.save!
          @team.save!

          @params = {
            :parent_name => 'wu fu',
            :name => @junior.name,
            :email => 'wu@fu.com',
            :mobile_number => "+440000000000",
            :id => @junior.id
          }
        end

        def add_second_parent
          TeamUsersService.should_receive(:add_parent).once.with(@team, kind_of(User), true, @signed_in_user)
          @signed_in_user.should_receive(:time_zone).and_return(0)
          
          #add second parent
          post :create, user: @params, team_id: @team_id, save_type: UserInvitationTypeEnum::LINKED_PARENT_JUNIOR, format: :json
          @junior.reload

          @new_parent = (@junior.parents - [@first_parent])
          @new_parent.size.should == 1
          @new_parent = @new_parent.first
        end

        it 'returns success' do
          add_second_parent
          response.status.should == HTTPResponseCodeEnum::OK
        end

        it 'creates a new parent user' do
          expect { add_second_parent }.to change {User.count}.by(1)
          @new_parent.should_not be_nil
          @new_parent.type.should_not == JuniorUser
        end

        it 'returns the new parent and junior json' do
          add_second_parent
          response.should render_template("api/v1/users/index")
        end

        it 'assoicates the parent to the junior' do
          add_second_parent
          @junior.parents.count.should == 2
          @junior.parents.should include @first_parent
          @junior.parents.should include User.last
        end

        it 'gives the new parent an invited role' do
          add_second_parent
          @new_parent.should have_role RoleEnum::INVITED
        end
      end

			context 'inviting a junior' do
				context 'parent user already registered' do
					it 'should add that user to the team and shit' do
						@user = FactoryGirl.create(:user) 

						User.should_receive(:find_by_email).with(@user_attrs[:email]).and_return(@user)
						User.should_not_receive(:create!)
						TeamUsersService.should_receive(:add_parent).once.with(@team, @user, true, @signed_in_user)
						TeamUsersService.should_receive(:add_player).once.with(@team, kind_of(User), false)

						lambda{ do_create(UserInvitationTypeEnum::LINKED_PARENT_JUNIOR) }.should change(User, :count).by(1)

						response.status.should eq(200)
						User.last.is_a?(JuniorUser).should eq(true)
						User.last.role?(RoleEnum::INVITED).should eq(false)
						User.last.role?(RoleEnum::REGISTERED).should eq(true)
					end
				end

				context 'user not registered yet' do
					it 'should create a new user and add them' do
						TeamUsersService.should_receive(:add_parent).once.with(@team, kind_of(User), true, @signed_in_user)
						TeamUsersService.should_receive(:add_player).once.with(@team, kind_of(JuniorUser), false)
						@signed_in_user.should_receive(:time_zone).and_return(0)

						lambda{ do_create(UserInvitationTypeEnum::LINKED_PARENT_JUNIOR) }.should change(User, :count).by(2)

						response.status.should eq(200)
						User.last.type.should eq("JuniorUser")
						User.last.role?(RoleEnum::INVITED).should eq(true)
						User.last.role?(RoleEnum::REGISTERED).should eq(false)
					end
				end
			end
		end
	end

	# old tests (from users/user_reg_contr_spec)
	context 'organiser logged in adding an exsiting user to an existing team' do
      login_team_organiser

      before :each do
        @existing_user = FactoryGirl.create(:user, :time_zone => "Nagaland")
        @existing_user_invitation_type = @existing_user.invited_by_source
        @user = subject.current_user 
        @team = @user.teams_as_organiser.first
        @team_count = Team.count
        @team.players.should_not include @existing_user
        email = @existing_user.email
        @user_count = User.count
        request_params = { :email => @existing_user.email }
        post :create, :save_type => UserInvitationTypeEnum::TEAM_PROFILE, :team_id => @team.id, :user => request_params, :format => :json
      end

      it 'creates the user' do
        User.count.should == @user_count
      end

      it 'does not create a new team' do
        Team.count.should == @team_count
      end

      it 'adds the user to the team' do
        @team.reload
        @team.players.should include @existing_user
      end

      it 'does not log the invitation type against the user' do
        @existing_user.invited_by_source.should eql @existing_user_invitation_type
      end

      it 'does not sets the timezone based on the team founders timezone' do
        @existing_user.time_zone.should_not == @team.founder.time_zone
      end

      it 'returns success' do
        response.header['Content-Type'].should include 'json'
        response.status.should == HTTPResponseCodeEnum::OK
      end
    end

    context 'organiser logged in adding a new user to an existing team' do
      login_team_organiser

      before :each do
        @user = subject.current_user 
        @team = @user.teams_as_organiser.first
        @team_count = Team.count
        email = "test@bluefields.com"
        request_params = FactoryGirl.attributes_for(:user, :email => email, :time_zone => "Africa/Lagos")
        post :create, :save_type => UserInvitationTypeEnum::TEAM_PROFILE, :team_id => @team.id, :user => request_params, :format => :json

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
        @new_user.invited_by_source.should eql UserInvitationTypeEnum::TEAM_PROFILE
      end

      it 'sets the timezone based on the team founders timezone' do
        @new_user.time_zone.should == @team.founder.time_zone
      end

      it 'returns success' do
        response.header['Content-Type'].should include 'json'
        response.status.should == HTTPResponseCodeEnum::OK
      end
    end


    context 'organiser logged in adding a new user to an event they own but specifying a team they dont own' do
      login_team_organiser
      
      before :each do
        @user = subject.current_user 
        @another_user = FactoryGirl.create(:user, :with_team_events)

        @team = @user.teams_as_organiser.first
        @another_user_team = @another_user.teams_as_organiser.first
        @team_count = Team.count
        @event = @team.events.first

        email = "test@bluefields.com"
        request_params = FactoryGirl.attributes_for(:user, :email => email)
        post :create, :save_type => UserInvitationTypeEnum::EVENT, :team_id => @another_user_team.id, :event_id => @event.id, :user => request_params, :format => 'html'
        
        @new_user = User.find_by_email(email)
      end

      it 'does not create the user' do
        @new_user.should be_nil
      end
      
      it 'does not create a new team' do
        Team.count.should == @team_count
      end

      it 'returns an error' do
        response.code.to_i.should == 401
      end
    end

    context 'organiser logged in adding a new user to an event' do
      login_team_organiser
      
      before :each do
        @user = subject.current_user 
        @team = @user.teams_as_organiser.first
        @team_count = Team.count
        @event = @team.events.first
      end

      context 'with event_id' do

        before(:each) do
          email = "test@bluefields.com"
          request_params = FactoryGirl.attributes_for(:user, :email => email)
          AddPlayerToEventWorker.stub(:perform_async) do |event_id, user_id|
            user = User.find_by_email(request_params[:email])
            AddPlayerToEventWorker.new.perform(event_id, user.id, false)
          end
          post :create, :save_type => UserInvitationTypeEnum::EVENT, :team_id => @team.id, :event_id => @event.id, :user => request_params, :format => :json
        
          @new_user = User.find_by_email(email)
        end

        it 'creates the user' do
          @new_user.should_not be_nil
          @new_user.should be_valid
        end
        
        it 'does not create a new team' do
          Team.count.should == @team_count
        end

        it 'adds the user to the event' do
          TeamsheetEntry.find_by_event_and_user(@event, @new_user).should_not be_nil
        end

        it 'adds the user to the team' do
          @team.players.should include @new_user
        end

        it 'sets the timezone based on the team founders timezone' do
          @new_user.time_zone.should == @team.founder.time_zone
        end

        it 'logs the invitation type against the user' do
          @new_user.invited_by_source.should eql UserInvitationTypeEnum::EVENT
        end

        it 'returns success' do
          response.header['Content-Type'].should include 'json'
          response.status.should == HTTPResponseCodeEnum::OK
        end
      end

      context 'without event_id' do

        before(:each) do
          email = "test@bluefields.com"
          request_params = FactoryGirl.attributes_for(:user, :email => email)
          post :create, :save_type => UserInvitationTypeEnum::EVENT, :team_id => @team.id, :user => request_params, :format => :json
        
          @new_user = User.find_by_email(email)
        end

        it 'creates the user' do
          @new_user.should_not be_nil
          @new_user.should be_valid
        end
        
        it 'does not create a new team' do
          Team.count.should == @team_count
        end

        it 'does not add the user to the event' do
          #TODO - this has changed because we add players to all future events automatically now!
          #TeamsheetEntry.find_by_event_and_user(@event, @new_user).should be_nil
        end
        
        it 'returns success' do
          response.header['Content-Type'].should include 'json'
          response.status.should == HTTPResponseCodeEnum::OK
        end
      end      
    end
    
    context 'non organiser logged in adding a new user to an event' do
      login_team_organiser
      
      before :each do
        @user = subject.current_user 
        @another_user = FactoryGirl.create(:user, :with_team_events)

        @team = @another_user.teams_as_organiser.first
        @team_count = Team.count
        @event = @team.events.first

        email = "test@bluefields.com"
        request_params = FactoryGirl.attributes_for(:user, :email => email)
        post :create, :save_type => UserInvitationTypeEnum::EVENT, :team_id => @team.id, :event_id => @event.id, :user => request_params, :format => 'html'
        
        @new_user = User.find_by_email(email)
      end

      it 'does not create the user' do
        @new_user.should be_nil
      end
      
      it 'does not create a new team' do
        Team.count.should == @team_count
      end

      it 'returns an error' do
        response.code.to_i.should == 401
      end
    end
end