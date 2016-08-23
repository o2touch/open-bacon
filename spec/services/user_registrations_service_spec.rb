require 'spec_helper'

describe UserRegistrationsService do
	def mock_team
    mock = FactoryGirl.build :team
    mock.stub(id:1)
    mock.stub(goals:GoalChecklist.new)
    mock.stub(schedule_last_sent:true)
    mock.stub(future_events:[])
    mock
  end

	describe '#complete_registration' do
		before :each do
			@user = FactoryGirl.build :user
			@user.stub(id: 2)
			@user.stub(email: "tpsherratt@googlemail.com")
			@user.stub(:add_role)
			@user.stub(:delete_role)
			@params = {}
		end

		context 'save_type == NORMAL' do
			before :each do
				@params = { 'team_id' => '09w85q9837918749087214' }
			end

			it 'raises an error if invalid team_uuid' do
				Team.should_receive(:find_by_uuid).and_return(nil)
				expect { UserRegistrationsService.complete_registration(@user, UserInvitationTypeEnum::NORMAL, @params) }.to raise_error
			end

			it 'does shit' do
				# adds the organiser
				@team = mock_team
				@team.stub!(:created_by_id=)
				TeamUsersService.should_receive(:add_organiser).with(@team, @user)
				Team.should_receive(:find_by_uuid).and_return(@team)

				# checks authorization
				auth = double("auth")
				auth.should_receive(:authorize!).with(:become_organiser, @team).and_return(true)
				Ability.should_receive(:new).and_return(auth)


				UserRegistrationsService.complete_registration(@user, UserInvitationTypeEnum::NORMAL, @params)
			end
		end

		context 'save_type == SIGNUPFLOW' do
			it 'should do the same as NORMAL' do
				@user = double("user")
				@user.should_receive(:add_role)
				@user.should_receive(:delete_role)
				@params = double("params")
				UserRegistrationsService.should_receive(:normal).with(@user, @params)
				UserRegistrationsService.complete_registration(@user, "SIGNUPFLOW", @params)
			end
		end

		context 'save_type == USER' do
			it 'should set teh tenant' do
				params = { tenant_id: 1 }

				UserRegistrationsService.complete_registration(@user, "USER", @params)

				@user.tenant.should eq(LandLord.default_tenant)
			end
		end

		context 'save_type == EVENT' do
			it 'does shit' do
				@params = {
					event_id: 1,
					user: {
						authorization: {
							token: "token",
							uid: "uid"
						}
					}
				}
				@event = double("event")
				@team = double("team")
				@team.stub(id: 1231)
				@event.stub(team: @team)
				@event.stub(id: 1231)
				@role = double("role")

				Event.should_receive(:find).and_return(@event)

				auth = double("auth")
				auth.should_receive(:authorize!).with(:join_as_player, @team).and_return(true)
				Ability.should_receive(:new).and_return(auth)

				TeamUsersService.should_receive(:add_player).with(@team, @user, false, nil, false).and_return(@role)
				@user.authorizations.should_receive(:create).with({
					token: "token",
					uid: "uid",
					provider: "Facebook",
					name: @user.name
				})


				AppEventService.should_receive(:create).with(@role, kind_of(User), "created", kind_of(Hash))

				UserRegistrationsService.complete_registration(@user, "EVENT", @params)
			end
		end

		context 'save_type = CONFIRM_USER' do
			it 'does shit' do
				# checks authorization
				auth = double("auth")
				auth.should_receive(:authorize!).with(:confirm, @user).and_return(true)
				Ability.should_receive(:new).and_return(auth)

				# update passwords
				@params = { user: { password: "password" }}
				@user.should_receive(:update_attributes!)

				# update child roles
				child = double("child")
				child.should_receive(:delete_role).with(RoleEnum::INVITED)
				child.should_receive(:add_role).with(RoleEnum::REGISTERED)
				@user.should_receive(:children).and_return([child])

				# send some emails
				EventNotificationService.should_receive(:invited_user_registered).with(@user)


				UserRegistrationsService.complete_registration(@user, UserInvitationTypeEnum::CONFIRM_USER, @params)
			end
		end

		context 'save_type == TEAMFOLLOW' do
			
			before :each do
				@params = { 'id' => '1234456789'}
			end

			it 'adds the user to the team as a follower' do
				@team = mock_team
				@team.stub(config: double(team_followable: true))
				@team.stub(:is_public?).and_return(true)
				Team.should_receive(:find).and_return(@team)
				@team.should_receive(:add_follower).with(@user)
				@team.should_receive(:faft_team?).and_return(true)

				AppEventService.should_receive(:create).with(@user, @user, "follower_registered", {team_id:1})
				UserRegistrationsService.complete_registration(@user, UserInvitationTypeEnum::TEAM_FOLLOW, @params)
			end
		end
	end
end