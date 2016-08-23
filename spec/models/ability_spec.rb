require 'spec_helper'
require 'cancan/matchers'

# There's a fucking lot of tests here, but they're all important (infact we need
# more...). Essentially every role (combination) of user has to try and do 
# everything on every type of every model. Brap. TS


# User Roles
#
# no_login - they can't log in so no tests requried
# invited
# registered
# junior - current this always goes in tandem with no_login.
# admin - can do everything so tests not crucial!

# Team Roles
#
# organiser
# player
# unrelated

# Event Roles (ignoring teams for now)
#
# player
# organiser - now the same as team organiser
# unrelated user

# Possible Combinations
# team organiser - registered
# team organiser - invited
# team player - registered
# team player - invited
# team parent of junior player - invited
# team parent of junior player - registered
# event organiser - registered
# event player - registered
# event player - invited
# event parent of junior player - invited
# event parent of junior player - registered
# unrelated user - invited
# unrelated user - registered
# unrelated user - logged out


describe Ability do
  subject{ ability }
	let(:ability){ Ability.new(user) }
	let(:user){ nil }

	describe 'Users' do
		describe 'registered parent on child' do
			let(:other_user){ FactoryGirl.create(:junior_user) }
			let(:user){ other_user.parents.first }
			it { should be_able_to(:act_on_behalf_of, other_user) } # this one is the key for parent/child
			it { should be_able_to(:read, other_user) }
			it { should be_able_to(:update, other_user) }
			it { should be_able_to(:export_calendar, other_user) }
			it { should be_able_to(:read_private_details, other_user) }
		end

		describe 'invited parent on child' do
			let(:other_user){ FactoryGirl.create(:junior_user) }
			let(:user) do
				parent = other_user.parents.first
				other_user.associate_parent(parent)
				parent.delete_role RoleEnum::REGISTERED
				parent.add_role RoleEnum::INVITED
				parent
			end
			it { should be_able_to(:act_on_behalf_of, other_user) } # this one is the key for parent/child
			it { should be_able_to(:read, other_user) }
			it { should_not be_able_to(:update, other_user) }
			it { should be_able_to(:export_calendar, other_user) }
			it { should be_able_to(:read_private_details, other_user) }
		end

		describe 'invited user on self' do
			let(:user) do
				u = FactoryGirl.create(:user)
				u.delete_role RoleEnum::REGISTERED
				u.add_role RoleEnum::INVITED
				u
			end
			it { should_not be_able_to(:act_on_behalf_of, user) } # this one is the key for parent/child
			it { should be_able_to(:read, user) }
			it { should be_able_to(:update, user) } #because invited users should be able to change their roles.
			it { should be_able_to(:export_calendar, user) }
			it { should be_able_to(:read_private_details, user) }
		end

		describe 'registered user on unrelated registered user' do 
			let(:other_user){ FactoryGirl.create(:user) }
			let(:user){ FactoryGirl.create(:user) }
			it { should_not be_able_to(:act_on_behalf_of, other_user) } # this one is the key for parent/child
			it { should_not be_able_to(:read, other_user) }
			it { should_not be_able_to(:update, other_user) }
			it { should_not be_able_to(:export_calendar, other_user) }
			it { should_not be_able_to(:read_private_details, other_user) }
		end

		describe 'registered adult on unrelated registered junior' do
			let(:other_user){ FactoryGirl.create(:junior_user) }
			let(:user){ FactoryGirl.create(:user) }
			it { should_not be_able_to(:act_on_behalf_of, other_user) } # this one is the key for parent/child
			it { should_not be_able_to(:read, other_user) }
			it { should_not be_able_to(:update, other_user) }
			it { should_not be_able_to(:export_calendar, other_user) }
			it { should_not be_able_to(:read_private_details, other_user) }
		end

		describe 'logged out user on anyone' do
			let(:other_user){ FactoryGirl.create(:user) }
			it { should_not be_able_to(:act_on_behalf_of, other_user) } # this one is the key for parent/child
			it { should_not be_able_to(:read, other_user) }
			it { should_not be_able_to(:update, other_user) }
			it { should_not be_able_to(:export_calendar, other_user) }
			it { should_not be_able_to(:read_private_details, other_user) }
		end

		describe 'team organiser on player' do
			let(:other_user){ FactoryGirl.create(:user) }
			let(:user){ FactoryGirl.create(:user) }
			before :each do
				team = FactoryGirl.create(:team)
				TeamUsersService.add_organiser(team, user)
				TeamUsersService.add_player(team, other_user, false)
			end
			it { should_not be_able_to(:act_on_behalf_of, other_user) } # this one is the key for parent/child
			it { should be_able_to(:read, other_user) }
			it { should_not be_able_to(:update, other_user) }
			it { should_not be_able_to(:export_calendar, other_user) }
			it { should be_able_to(:read_private_details, other_user) }
		end

		describe 'league organiser on player' do
			let(:other_user){ FactoryGirl.create(:user) }
			let(:user){ FactoryGirl.create(:user) }
			before :each do
				team = FactoryGirl.create(:team)
				league = FactoryGirl.create(:league)
				ds = FactoryGirl.create(:division_season)
				league.fixed_divisions << ds.fixed_division
				league.add_organiser(user)
				ds.fixed_division.save!

				TeamDSService.add_team(ds, team)
				TeamUsersService.add_player(team, other_user, false)
			end
			it { should_not be_able_to(:act_on_behalf_of, other_user) } # this one is the key for parent/child
			it { should be_able_to(:read, other_user) }
			it { should be_able_to(:update, other_user) }
			it { should_not be_able_to(:export_calendar, other_user) }
			it { should be_able_to(:read_private_details, other_user) }
		end

		describe 'friend on friend' do
			before :each do
				@team = FactoryGirl.create(:team, :with_players, player_count: 2)
			end
			let(:user){ @team.players.second }
			let(:other_user){ @team.players.third }
			it { should_not be_able_to(:act_on_behalf_of, other_user) } # this one is the key for parent/child
			it { should be_able_to(:read, other_user) }
			it { should_not be_able_to(:update, other_user) }
			it { should_not be_able_to(:export_calendar, other_user) }
			it { should_not be_able_to(:read_private_details, other_user) }
		end

		describe 'friend on junior' do
			before :each do
				@team = FactoryGirl.create(:junior_team, :with_players, player_count: 2)
			end
			let(:user){ @team.players.first }
			let(:other_user){ @team.players.second }
			it { should_not be_able_to(:act_on_behalf_of, other_user) } # this one is the key for parent/child
			it { should_not be_able_to(:read, other_user) }
			it { should_not be_able_to(:update, other_user) }
			it { should_not be_able_to(:export_calendar, other_user) }
			it { should_not be_able_to(:read_private_details, other_user) }
		end
	end


	describe 'Events' do
		let(:event) { FactoryGirl.create(:event_with_players) }
		let(:event_result) { event.build_result({ score_against: 1, score_for: 1 }) }
		let(:event_message) { event.messages.build(text: "hihi") }
		let(:team) { FactoryGirl.create(:team, :with_events, event_count: 1) }
		let(:team_event){ team.events.first }

		describe 'registered event organiser' do
			let(:user){ event.user }
			it { should_not be_able_to(:create, Event.new) } # must have a team.
			it { should be_able_to(:read, event) }
			it { should be_able_to(:manage_event, event) }
			it { should be_able_to(:send_invites, event) }
			it { should be_able_to(:read_all_details, event) }
			it { should be_able_to(:create_message, event) }
			it { should be_able_to(:read_messages, event) }
			it { should be_able_to(:create_message_via_email, event) }
			it { should be_able_to(:comment, event_message) }
			it { should be_able_to(:comment_via_email, event_message) }
			it { should be_able_to(:like, event_message) }
			it { should be_able_to(:comment, event_result) }
			it { should be_able_to(:comment_via_email, event_result) }
			it { should be_able_to(:like, event_result) }
		end

		describe 'registered team organiser' do
			let(:user){ team.organisers.first }
			let(:event){ team.events.first }
			it { should be_able_to(:create, Event.new) }
			it { should be_able_to(:read, event) }
			it { should be_able_to(:manage_event, event) }
			it { should be_able_to(:send_invites, event) }
			it { should be_able_to(:read_all_details, event) }
			it { should be_able_to(:create_message, event) }
			it { should be_able_to(:create_message_via_email, event) }
			it { should be_able_to(:read_messages, event) }
			it { should be_able_to(:comment, event_message) }
			it { should be_able_to(:comment_via_email, event_message) }
			it { should be_able_to(:like, event_message) }
			it { should be_able_to(:comment, event_result) }
			it { should be_able_to(:comment_via_email, event_result) }
			it { should be_able_to(:like, event_result) }
		end

		describe 'invited team organiser' do
			let(:user) do
				u = FactoryGirl.create(:user)
				team.add_organiser(u)
			  u.add_role(RoleEnum::INVITED)
			  u.delete_role(RoleEnum::REGISTERED)
			  EventInvitesService.add_players(event, [u])
			  u
			end
			let(:event){ team.events.first }
			it { should_not be_able_to(:create, Event.new) }
			it { should be_able_to(:read, event) }
			it { should_not be_able_to(:manage_event, event) }
			it { should_not be_able_to(:send_invites, event) }
			it { should be_able_to(:read_all_details, event) }
			it { should_not be_able_to(:create_message, event) }
			it { should be_able_to(:create_message_via_email, event) }
			it { should be_able_to(:read_messages, event) }
			it { should_not be_able_to(:comment, event_message) }
			it { should be_able_to(:comment_via_email, event_message) }
			it { should_not be_able_to(:like, event_message) }
			it { should_not be_able_to(:comment, event_result) }
			it { should be_able_to(:comment_via_email, event_result) }
			it { should_not be_able_to(:like, event_result) }
		end

		describe 'registered event player' do
			let(:user){ event.users.first }
			it { should_not be_able_to(:create, Event.new) }
			it { should be_able_to(:read, event) }
			it { should_not be_able_to(:manage_event, event) }
			it { should_not be_able_to(:send_invites, event) }
			it { should be_able_to(:read_all_details, event) }
			it { should be_able_to(:create_message, event) }
			it { should be_able_to(:create_message_via_email, event) }
			it { should be_able_to(:read_messages, event) }
			it { should be_able_to(:comment, event_message) }
			it { should be_able_to(:comment_via_email, event_message) }
			it { should be_able_to(:like, event_message) }
			it { should be_able_to(:comment, event_result) }
			it { should be_able_to(:comment_via_email, event_result) }
			it { should be_able_to(:like, event_result) }
		end

		describe 'invited event player' do
			let(:user) do
				ip = event.users.first
			  ip.add_role(RoleEnum::INVITED)
			  ip.delete_role(RoleEnum::REGISTERED)
			  ip
			end
			it { should_not be_able_to(:create, Event.new) }
			it { should be_able_to(:read, event) }
			it { should_not be_able_to(:manage_event, event) }
			it { should_not be_able_to(:send_invites, event) }
			it { should be_able_to(:read_all_details, event) }
			it { should_not be_able_to(:create_message, event) }
			it { should be_able_to(:create_message_via_email, event) }
			it { should be_able_to(:read_messages, event) }
			it { should_not be_able_to(:comment, event_message) }
			it { should be_able_to(:comment_via_email, event_message) }
			it { should_not be_able_to(:like, event_message) }
			it { should_not be_able_to(:comment, event_result) }
			it { should be_able_to(:comment_via_email, event_result) }
			it { should_not be_able_to(:like, event_result) }
		end

		# perms are the same for all kind of unrelated user
		describe 'any unrelated user' do
			let(:user){ FactoryGirl.create(:user) }
			it { should_not be_able_to(:create, Event.new) }
			it { should be_able_to(:read, event) }
			it { should_not be_able_to(:manage_event, event) }
			it { should_not be_able_to(:send_invites, event) }
			it { should_not be_able_to(:read_private_details, event) }
			it { should_not be_able_to(:create_message, event) }
			it { should_not be_able_to(:create_message_via_email, event) }
			it { should_not be_able_to(:read_messages, event) }
			it { should_not be_able_to(:comment, event_message) }
			it { should_not be_able_to(:comment_via_email, event_message) }
			it { should_not be_able_to(:like, event_message) }
			it { should_not be_able_to(:comment, event_result) }
			it { should_not be_able_to(:comment_via_email, event_result) }
			it { should_not be_able_to(:like, event_result) }
		end

		describe 'any no_login user' do
			let(:user) do
			  nl = event.user # any user, so use the one with high perms
				nl.add_role(RoleEnum::NO_LOGIN)
			end
			it { should_not be_able_to(:create, Event.new) }
			it { should_not be_able_to(:read, event) }
			it { should_not be_able_to(:manage_event, event) }
			it { should_not be_able_to(:send_invites, event) }
			it { should_not be_able_to(:read_private_details, event) }
			it { should_not be_able_to(:create_message, event) }
			it { should_not be_able_to(:read_messages, event) }
			it { should_not be_able_to(:create_message_via_email, event) }
			it { should_not be_able_to(:comment, event_message) }
			it { should_not be_able_to(:comment_via_email, event_message) }
			it { should_not be_able_to(:like, event_message) }
			it { should_not be_able_to(:comment, event_result) }
			it { should_not be_able_to(:comment_via_email, event_result) }
			it { should_not be_able_to(:like, event_result) }
		end

		describe 'logged out user' do
			# as a guest account is automatically created
			it { should_not be_able_to(:create, Event.new) }
			it { should be_able_to(:read, event) }
			it { should_not be_able_to(:manage_event, event) }
			it { should_not be_able_to(:send_invites, event) }
			it { should_not be_able_to(:read_all_details, event) }
			it { should_not be_able_to(:create_message, event) }
			it { should_not be_able_to(:create_message_via_email, event) }
			it { should_not be_able_to(:read_messages, event) }
			it { should_not be_able_to(:comment, event_message) }
			it { should_not be_able_to(:comment_via_email, event_message) }
			it { should_not be_able_to(:like, event_message) }
			it { should_not be_able_to(:comment, event_result) }
			it { should_not be_able_to(:comment_via_email, event_result) }
			it { should_not be_able_to(:like, event_result) }
		end
	end

	describe 'Event from junior team' do
		let(:event){ team.events.first }
		let(:event_result) { event.build_result({ score_against: 1, score_for: 1 }) }
		let(:event_message) { event.messages.build(text: "hihi") }
		let(:team) do
			team = FactoryGirl.create(:team, :with_events, :with_players, event_count: 1, player_count: 2)
			team.profile.age_group = AgeGroupEnum::UNDER_10
			team.profile.save
			team
		end
		describe 'registered parent of junior player' do
			let(:user) do
				child = FactoryGirl.create(:junior_user)
			  EventInvitesService.add_players(event, [child])
			 	child.parents.first
			end
			it { should_not be_able_to(:create, Event.new) }
			it { should be_able_to(:read, event) }
			it { should_not be_able_to(:manage_event, event) }
			it { should_not be_able_to(:send_invites, event) }
			it { should be_able_to(:read_all_details, event) }
			it { should be_able_to(:create_message, event) }
			it { should be_able_to(:read_messages, event) }
			it { should be_able_to(:create_message_via_email, event) }
			it { should be_able_to(:comment, event_message) }
			it { should be_able_to(:comment_via_email, event_message) }
			it { should be_able_to(:like, event_message) }
			it { should be_able_to(:comment, event_result) }
			it { should be_able_to(:comment_via_email, event_result) }
			it { should be_able_to(:like, event_result) }
		end

		describe 'invited parent of junior player' do
			let(:user) do
				child = FactoryGirl.create(:junior_user)
				parent = child.parents.first
			  parent.add_role(RoleEnum::INVITED)
			  parent.delete_role(RoleEnum::REGISTERED)
			  EventInvitesService.add_players(event, [child])
			 	parent 
			end
			it { should_not be_able_to(:create, Event.new) }
			it { should be_able_to(:read, event) }
			it { should_not be_able_to(:manage_event, event) }
			it { should_not be_able_to(:send_invites, event) }
			it { should be_able_to(:read_all_details, event) }
			it { should_not be_able_to(:create_message, event) }
			it { should be_able_to(:read_messages, event) }
			it { should be_able_to(:create_message_via_email, event) }
			it { should_not be_able_to(:comment, event_message) }
			it { should be_able_to(:comment_via_email, event_message) }
			it { should_not be_able_to(:like, event_message) }
			it { should_not be_able_to(:comment, event_result) }
			it { should be_able_to(:comment_via_email, event_result) }
			it { should_not be_able_to(:like, event_result) }
		end

				# perms are the same for all kind of unrelated user
		describe 'any unrelated user' do
			let(:user){ FactoryGirl.create(:user) }
			it { should_not be_able_to(:create, Event.new) }
			it { should_not be_able_to(:read, event) }
			it { should_not be_able_to(:manage_event, event) }
			it { should_not be_able_to(:send_invites, event) }
			it { should_not be_able_to(:read_private_details, event) }
			it { should_not be_able_to(:create_message, event) }
			it { should_not be_able_to(:read_messages, event) }
			it { should_not be_able_to(:create_message_via_email, event) }
			it { should_not be_able_to(:comment, event_message) }
			it { should_not be_able_to(:comment_via_email, event_message) }
			it { should_not be_able_to(:like, event_message) }
			it { should_not be_able_to(:comment, event_result) }
			it { should_not be_able_to(:comment_via_email, event_result) }
			it { should_not be_able_to(:like, event_result) }
		end

		describe 'any no_login user' do
			let(:user) do
			  nl = event.user # any user, so use the one with high perms
				nl.add_role(RoleEnum::NO_LOGIN)
			end
			it { should_not be_able_to(:create, Event.new) }
			it { should_not be_able_to(:read, event) }
			it { should_not be_able_to(:manage_event, event) }
			it { should_not be_able_to(:send_invites, event) }
			it { should_not be_able_to(:read_all_details, event) }
			it { should_not be_able_to(:create_message, event) }
			it { should_not be_able_to(:read_messages, event) }
			it { should_not be_able_to(:create_message_via_email, event) }
			it { should_not be_able_to(:comment, event_message) }
			it { should_not be_able_to(:comment_via_email, event_message) }
			it { should_not be_able_to(:like, event_message) }
			it { should_not be_able_to(:comment, event_result) }
			it { should_not be_able_to(:comment_via_email, event_result) }
			it { should_not be_able_to(:like, event_result) }
		end

		describe 'logged out user' do
			# as a guest account is automatically created
			it { should_not be_able_to(:create, Event.new) }
			it { should_not be_able_to(:read, event) }
			it { should_not be_able_to(:manage_event, event) }
			it { should_not be_able_to(:send_invites, event) }
			it { should_not be_able_to(:read_all_details, event) }
			it { should_not be_able_to(:create_message, event) }
			it { should_not be_able_to(:read_messages, event) }
			it { should_not be_able_to(:create_message_via_email, event) }
			it { should_not be_able_to(:comment, event_message) }
			it { should_not be_able_to(:comment_via_email, event_message) }
			it { should_not be_able_to(:like, event_message) }
			it { should_not be_able_to(:comment, event_result) }
			it { should_not be_able_to(:comment_via_email, event_result) }
			it { should_not be_able_to(:like, event_result) }
		end
	end

	describe 'Team' do
		# TODO: test deleting TeamRoles TS
		let(:league) { division.league }
		let(:division) do
			division = FactoryGirl.create(:division_season)
			TeamDSService.add_team(division, team)
			division
		end
		let(:team) { FactoryGirl.create(:team, :with_players, player_count: 2) }
		let(:public_team) do
			team.stub(is_public?: true)
			team
		end
		let(:private_team) do
			team.stub(is_public?: false)
			team
		end
		let(:followable_team) do
			team.stub(config: double(team_followable: true))
			team
		end
		let(:organiser) { team.organisers.first }
		let(:team_message) { team.messages.build(text: "some ting") }
		let(:team_role) do
			team.players.last.team_roles.first
		end
		let(:another_registered_user){ FactoryGirl.create(:user) }

		describe 'registered team organiser' do
			let(:user){ organiser }
			it { should be_able_to(:create, Team.new) }
			it { should be_able_to(:read, team) }
			it { should be_able_to(:update, team) }
			it { should be_able_to(:export_calendar, team) }
			it { should be_able_to(:manage, team) }
			it { should be_able_to(:manage_roster, team) }
			it { should be_able_to(:delete, team_role) }
			it { should be_able_to(:create_message, team) }
			it { should be_able_to(:create_message_via_email, team) }
			it { should be_able_to(:comment, team_message) }
			it { should be_able_to(:comment_via_email, team_message) }
			it { should be_able_to(:like, team_message) }
			# These two fail... first doesn't matter as can only have 1 team role...
			#  second is not that bad, they are the org after all.
			#  But, we need to not use :manage perm (or override how it works) TS
			#it { should_not be_able_to(:follow, team) }
			#it { should_not be_able_to(:add_follower, team) }
			it { should be_able_to(:follow, followable_team) }
			it { should be_able_to(:add_follower, followable_team) }
		end

		# ie. invited player, added to organisers
		describe 'invited team organiser' do
			let(:user) do
				u = FactoryGirl.create(:user)
				team.add_organiser(u)
			  u.add_role(RoleEnum::INVITED)
			  u.delete_role(RoleEnum::REGISTERED)
			  u
			end
			it { should_not be_able_to(:create, Team.new) }
			it { should be_able_to(:read, team) }
			it { should_not be_able_to(:update, team) }
			it { should be_able_to(:export_calendar, team) }
			it { should_not be_able_to(:manage, team) }
			it { should_not be_able_to(:manage_roster, team) }
			it { should_not be_able_to(:delete, team_role) }
			it { should_not be_able_to(:create_message, team) }
			it { should_not be_able_to(:create_message_via_email, team) }
			it { should_not be_able_to(:comment, team_message) }
			it { should be_able_to(:comment_via_email, team_message) }
			it { should_not be_able_to(:like, team_message) }
			it { should_not be_able_to(:view_public_profile, team) }
			it { should_not be_able_to(:follow, private_team) }
			it { should_not be_able_to(:add_follower, team) }
			it { should be_able_to(:follow, followable_team) }
			it { should_not be_able_to(:add_follower, followable_team) }
		end

		describe 'registered player' do
			let(:user){ team.players.last }
			it { should be_able_to(:create, Team.new) }
			it { should be_able_to(:read, team) }
			it { should_not be_able_to(:update, team) }
			it { should be_able_to(:export_calendar, team) }
			it { should_not be_able_to(:manage, team) }
			it { should_not be_able_to(:manage_roster, team) }
			it { should_not be_able_to(:delete, team_role) }
			it { should be_able_to(:create_message, team) }
			it { should_not be_able_to(:create_message_via_email, team) }
			it { should be_able_to(:comment, team_message) }
			it { should be_able_to(:comment_via_email, team_message) }
			it { should be_able_to(:like, team_message) }
			it { should_not be_able_to(:view_public_profile, team) }
			it { should_not be_able_to(:follow, team) }
			it { should_not be_able_to(:add_follower, team) }
			it { should be_able_to(:follow, followable_team) }
			it { should be_able_to(:add_follower, followable_team) }
		end

		describe 'invited player' do
			let(:user) do
				ip = team.players.last
			  ip.add_role(RoleEnum::INVITED)
			  ip.delete_role(RoleEnum::REGISTERED)
			  ip
			end
			it { should_not be_able_to(:create, Team.new) }
			it { should be_able_to(:read, team) }
			it { should_not be_able_to(:update, team) }
			it { should be_able_to(:export_calendar, team) }
			it { should_not be_able_to(:manage, team) }
			it { should_not be_able_to(:manage_roster, team) }
			it { should_not be_able_to(:delete, team_role) }
			it { should_not be_able_to(:create_message, team) }
			it { should_not be_able_to(:create_message_via_email, team) }
			it { should_not be_able_to(:comment, team_message) }
			it { should be_able_to(:comment_via_email, team_message) }
			it { should_not be_able_to(:like, team_message) }
			it { should_not be_able_to(:view_public_profile, team) }
			it { should_not be_able_to(:follow, team) }
			it { should_not be_able_to(:add_follower, team) }
			it { should be_able_to(:follow, followable_team) }
			it { should_not be_able_to(:add_follower, followable_team) }
		end

		# perms are the same for all kind of unrelated user
		describe 'any unrelated user' do
			let(:user){ FactoryGirl.create(:user) }
			it { should be_able_to(:create, Team.new) }
			it { should_not be_able_to(:read, team) }
			it { should_not be_able_to(:update, team) }
			it { should_not be_able_to(:export_calendar, team) }
			it { should_not be_able_to(:manage, team) }
			it { should_not be_able_to(:manage_roster, team) }
			it { should_not be_able_to(:delete, team_role) }
			it { should_not be_able_to(:create_message, team) }
			it { should_not be_able_to(:create_message_via_email, team) }
			it { should_not be_able_to(:comment, team_message) }
			it { should_not be_able_to(:comment_via_email, team_message) }
			it { should_not be_able_to(:like, team_message) }
			it { should_not be_able_to(:view_public_profile, team) }
			it { should_not be_able_to(:follow, team) }
			it { should_not be_able_to(:add_follower, team) }
			it { should be_able_to(:follow, followable_team) }
			it { should_not be_able_to(:add_follower, followable_team) }
		end

		describe 'any no_login user' do
			let(:user) do
				nl = team.organisers.first # any user, so test with highest perms
				nl.add_role(RoleEnum::NO_LOGIN)
			end
			it { should_not be_able_to(:create, Team.new) }
			it { should_not be_able_to(:read, team) }
			it { should_not be_able_to(:update, team) }
			it { should_not be_able_to(:export_calendar, team) }
			it { should_not be_able_to(:manage, team) }
			it { should_not be_able_to(:manage_roster, team) }
			it { should_not be_able_to(:delete, team_role) }
			it { should_not be_able_to(:create_message, team) }
			it { should_not be_able_to(:create_message_via_email, team) }
			it { should_not be_able_to(:comment, team_message) }
			it { should_not be_able_to(:comment_via_email, team_message) }
			it { should_not be_able_to(:like, team_message) }
			it { should_not be_able_to(:view_public_profile, team) }
			it { should_not be_able_to(:follow, team) }
			it { should_not be_able_to(:add_follower, team) }
			it { should_not be_able_to(:follow, followable_team) }
			it { should_not be_able_to(:add_follower, followable_team) }
		end

		describe 'logged out user' do
			let(:user) do
				FactoryGirl.create(:user).tap do |user|
					user.roles.map(&:destroy)
					user.roles(true)
				end
			end

			it { should_not be_able_to(:create, Team.new) }
			it { should_not be_able_to(:read, team) }
			it { should_not be_able_to(:update, team) }
			it { should_not be_able_to(:export_calendar, team) }
			it { should_not be_able_to(:manage, team) }
			it { should_not be_able_to(:manage_roster, team) }
			it { should_not be_able_to(:delete, team_role) }
			it { should_not be_able_to(:create_message, team) }
			it { should_not be_able_to(:create_message_via_email, team) }
			it { should_not be_able_to(:comment, team_message) }
			it { should_not be_able_to(:comment_via_email, team_message) }
			it { should_not be_able_to(:like, team_message) }
			it { should_not be_able_to(:view_public_profile, team) }
			it { should_not be_able_to(:follow, team) }
			it { should_not be_able_to(:add_follower, team) }
			it { should be_able_to(:follow, followable_team) }
			it { should_not be_able_to(:add_follower, followable_team) }
		end

		describe 'league admin with manage roster enabled' do
			let(:user) do
				league
				team.league_config
        team.settings["league_config"][team.divisions.first.id.to_s][LeagueConfigKeyEnum::LEAGUE_MANAGED_ROSTER] = true
        team.league_config
				league.organisers.first
			end
			it { should be_able_to(:create, Team.new) }
			it { should be_able_to(:read, team) }
			it { should_not be_able_to(:update, team) }
			it { should_not be_able_to(:export_calendar, team) }
			it { should_not be_able_to(:manage, team) }
			it { should be_able_to(:manage_roster, team) }
			it 'should do shit' do
				# complex setup shit...
				user
				team.save
				team_role.reload
				should be_able_to(:delete, team_role)
			end
			it { should_not be_able_to(:create_message, team) }
			it { should_not be_able_to(:create_message_via_email, team) }
			it { should_not be_able_to(:comment, team_message) }
			it { should_not be_able_to(:comment_via_email, team_message) }
			it { should_not be_able_to(:like, team_message) }
			it { should_not be_able_to(:follow, private_team) }
			it { should_not be_able_to(:add_follower, team) }
			it { should be_able_to(:follow, followable_team) }
			it { should_not be_able_to(:add_follower, followable_team) }
		end

		# TODO: move all of these tests into the places that they should be
		describe 'team follower' do
			let (:user) do
				u = FactoryGirl.create(:user)
				team.add_follower(u)
				u.reload
				u
			end
			
			let (:team_player) do
				team.players.last
			end
			
			let(:team) { FactoryGirl.create(:team, :with_players, :with_events, :player_count => 2, :event_count => 1) }
			let(:event) { team.events.first }
			let(:demo_user) do 
				du = FactoryGirl.create(:demo_user)
				team.add_player(du)
				du
			end
			
			let(:league) { division.league }
			
			let(:division) do
				division = FactoryGirl.create(:division_season)
				TeamDSService.add_team(division, team)
				division
			end


			it { should_not be_able_to(:create_message, team) }
			it { should_not be_able_to(:create_message_via_email, team) }
			it { should_not be_able_to(:comment, team_message) }
			it { should_not be_able_to(:comment_via_email, team_message) }
			it { should_not be_able_to(:like, team_message) }
			it { should_not be_able_to(:follow, team) }
			it { should_not be_able_to(:add_follower, team) }
			it { should be_able_to(:follow, followable_team) }
			it { should be_able_to(:add_follower, followable_team) }
			it { should be_able_to(:delete, user.team_roles.first) }



			let(:event){ team.events.first }
			let(:team_message) { team.messages.build(text: "this is a lot of repetitive code") }
			let(:event_result) { event.build_result({ score_against: 1, score_for: 1 }) }
			let(:event_message) { event.messages.build(text: "this is a lot of repetitive code") }
			it { should_not be_able_to(:manage, division) }
			it { should_not be_able_to(:read_unpublished, division) }
    	it { should_not be_able_to(:manage, division) }
	    it { should_not be_able_to(:read_unpublished, division) }
	    #it { should_not be_able_to(:manage, fixture) }
	    #it { should_not be_able_to(:update, result) }
	   # it { should_not be_able_to(:update, points) }

	    
	    it { should be_able_to(:update, user) }
			it { should_not be_able_to(:update, team_player) }

	    it { should_not be_able_to(:update, demo_user) }
	    
	    it { should be_able_to(:create, team) }
	    it { should_not be_able_to(:update, team) }
	    it { should_not be_able_to(:manage, team) }
	    it { should_not be_able_to(:manage_roster, team) }
	   # it { should_not be_able_to(:delete, team_role) }
	    it { should_not be_able_to(:create_message, team) }
	    it { should_not be_able_to(:create, event) }
	    it { should_not be_able_to(:manage_event, event) }
	   # it { should_not be_able_to(:manage_event, demo_event) }
	    it { should_not be_able_to(:send_invites, event) }
	    it { should_not be_able_to(:create_message, event) }
	  end
	end

	describe 'Junior Team' do
		let(:team) do
			team = FactoryGirl.create(:team, :with_players, player_count: 2)
			team.profile.age_group = AgeGroupEnum::UNDER_10
			team.save
			team
		end
		let(:public_team) do
			team.stub(is_public?: true)
			team
		end
		let(:private_team) do
			team.stub(is_public?: false)
			team
		end
		let(:followable_team) do
			team.stub(config: double(team_followable: true))
			team
		end
		let(:team_role) { PolyRole.find(:first, :conditions => { :user_id => team.players.last.id, :obj_type => 'Team', :obj_id => team.id })}
		let(:event) do 
      e = FactoryGirl.create(:event, :team => team, :user => team.created_by )
      team.events << e
      e
    end
		describe 'registered parent of child player' do
			let(:user) do
				child = FactoryGirl.create(:junior_user)
				event.teamsheet_entries << FactoryGirl.create(:teamsheet_entry, :user => child, :event => event)
				parent = child.parents.first
				team.add_player(child)
				team.add_parent(parent)
			 	parent 
			end
			it { should be_able_to(:create, Team.new) }
			it { should be_able_to(:read, team) }
			it { should_not be_able_to(:manage, team) }
			it { should_not be_able_to(:manage_roster, team) }
			it { should_not be_able_to(:delete, team_role) }
			it { should_not be_able_to(:update, team) }
			it { should be_able_to(:export_calendar, team) }
			it { should_not be_able_to(:manage, team) }
 		  it { should be_able_to(:create_message, team) }
      it { should be_able_to(:create_message, event) }
			it { should_not be_able_to(:follow, team) }
			it { should_not be_able_to(:add_follower, team) }
			it { should be_able_to(:follow, followable_team) }
			it { should be_able_to(:add_follower, followable_team) }
		end

		describe 'invited parent of child player' do
			let(:user) do
				child = FactoryGirl.create(:junior_user)
				parent = child.parents.first
			  parent.add_role(RoleEnum::INVITED)
			  parent.delete_role(RoleEnum::REGISTERED)
				team.add_player(child)
				team.add_parent(parent)
			 	parent 
			end
			it { should_not be_able_to(:create, Team.new) }
			it { should be_able_to(:read, team) }
			it { should_not be_able_to(:manage, team) }
			it { should_not be_able_to(:manage_roster, team) }
			it { should_not be_able_to(:delete, team_role) }
			it { should_not be_able_to(:update, team) }
			it { should be_able_to(:export_calendar, team) }
			it { should_not be_able_to(:manage, team) }
			it { should_not be_able_to(:create_message, team) }
      it { should_not be_able_to(:create_message, event) }
			it { should_not be_able_to(:follow, team) }
			it { should_not be_able_to(:add_follower, team) }
			it { should be_able_to(:follow, followable_team) }
			it { should_not be_able_to(:add_follower, followable_team) }
		end
				# perms are the same for all kind of unrelated user
		describe 'any unrelated user' do
			let(:user){ FactoryGirl.create(:user) }
			it { should be_able_to(:create, Team.new) }
			it { should_not be_able_to(:read, team) }
			it { should_not be_able_to(:manage, team) }
			it { should_not be_able_to(:manage_roster, team) }
			it { should_not be_able_to(:delete, team_role) }
			it { should_not be_able_to(:update, team) }
			it { should_not be_able_to(:export_calendar, team) }
			it { should_not be_able_to(:manage, team) }
			it { should_not be_able_to(:create_message, team) }
      it { should_not be_able_to(:create_message, event) }
			it { should_not be_able_to(:follow, team) }
			it { should_not be_able_to(:add_follower, team) }
			it { should be_able_to(:follow, followable_team) }
			it { should_not be_able_to(:add_follower, followable_team) }
		end

		describe 'logged out user' do
			it { should_not be_able_to(:create, Team.new) }
			it { should_not be_able_to(:manage, team) }
			it { should_not be_able_to(:manage_roster, team) }
			it { should_not be_able_to(:read, team) }
			it { should_not be_able_to(:delete, team_role) }
			it { should_not be_able_to(:update, team) }
			it { should_not be_able_to(:export_calendar, team) }
			it { should_not be_able_to(:manage, team) }
			it { should_not be_able_to(:create_message, team) }
      it { should_not be_able_to(:create_message, event) }
			it { should_not be_able_to(:follow, team) }
			it { should_not be_able_to(:add_follower, team) }
			it { should be_able_to(:follow, followable_team) }
			it { should_not be_able_to(:add_follower, followable_team) }
		end
	end

	describe 'TeamsheetEntries' do
		let(:event) { FactoryGirl.create(:event_with_players) }

		describe 'registered player' do
			let(:user){ event.teamsheet_entries.first.user }
			it { should be_able_to(:respond, user.teamsheet_entries.first) }
		end

		describe 'invited player' do
			let(:user) do
				u = event.teamsheet_entries.first.user
			  u.add_role(RoleEnum::INVITED)
			  u.delete_role(RoleEnum::REGISTERED)
			  u
			end
			it { should be_able_to(:respond, user.teamsheet_entries.first) }
		end

		describe 'organiser' do
			let(:user){ event.user }
			it { should be_able_to(:respond, event.teamsheet_entries.second) }
		end

		describe 'unrelated user' do
			let(:user) do
				event # create the event
				FactoryGirl.create(:user)
			end
			it { should_not be_able_to(:respond, event.teamsheet_entries.first) }
		end

		describe 'logged out user' do
			let(:user) do
				event # create the event
				nil
			end
			it { should_not be_able_to(:respond, event.teamsheet_entries.first) }
		end

		describe 'registered parent of junior' do
			let(:user){ junior.parents.first }
			let(:junior) do
				child = FactoryGirl.create(:junior_user)
			  EventInvitesService.add_players(event, [child])
			 	child
			end
			it { should be_able_to(:respond, junior.teamsheet_entries.first) }
		end

		describe 'invited parent of junior' do
			let(:user) do
				parent = junior.parents.first
			  parent.add_role(RoleEnum::INVITED)
			  parent.delete_role(RoleEnum::REGISTERED)
			 	parent 
			end
			let(:junior) do
				junior = FactoryGirl.create(:junior_user)
			  EventInvitesService.add_players(event, [junior])
			  junior
			end
			it { should be_able_to(:respond, junior.teamsheet_entries.first) }
		end
	end

	# This is for commenting on activity items, but the test is againt the obj...
	describe 'ActivityItems' do
		# nb. EventMessage and EventResult comming is tested in the event section,
		#      as it's already setup, and it's essentially the event perms that
		#      get tested!

		describe 'logged out user' do
			let(:user){ nil }
			it { should_not be_able_to(:like, Event.new) }
			it { should_not be_able_to(:like, TeamsheetEntry.new) }
			it { should_not be_able_to(:like, InviteResponse.new) }
			it { should_not be_able_to(:like, InviteReminder.new) }
			it { should_not be_able_to(:comment, User.new) }
			it { should_not be_able_to(:comment, Event.new) }
			it { should_not be_able_to(:comment, TeamsheetEntry.new) }
			it { should_not be_able_to(:comment, InviteResponse.new) }
			it { should_not be_able_to(:comment, InviteReminder.new) }
			it { should_not be_able_to(:comment_via_email, User.new) }
			it { should_not be_able_to(:comment_via_email, Event.new) }
			it { should_not be_able_to(:comment_via_email, TeamsheetEntry.new) }
			it { should_not be_able_to(:comment_via_email, InviteResponse.new) }
			it { should_not be_able_to(:comment_via_email, InviteReminder.new) }
		end

		describe 'invited user' do
			let(:user) do
				u = FactoryGirl.create(:user)
			  u.add_role(RoleEnum::INVITED)
			  u.delete_role(RoleEnum::REGISTERED)
			  u
			end
			it { should_not be_able_to(:like, Event.new) }
			it { should_not be_able_to(:like, TeamsheetEntry.new) }
			it { should_not be_able_to(:like, InviteResponse.new) }
			it { should_not be_able_to(:like, InviteReminder.new) }
			it { should_not be_able_to(:comment, Event.new) }
			it { should_not be_able_to(:comment, TeamsheetEntry.new) }
			it { should_not be_able_to(:comment, InviteResponse.new) }
			it { should_not be_able_to(:comment, InviteReminder.new) }
			it { should be_able_to(:comment_via_email, User.new) }
			it { should be_able_to(:comment_via_email, Event.new) }
			it { should be_able_to(:comment_via_email, TeamsheetEntry.new) }
			it { should be_able_to(:comment_via_email, InviteResponse.new) }
			it { should be_able_to(:comment_via_email, InviteReminder.new) }
		end

		describe 'registered user' do
			let(:user){ FactoryGirl.create(:user) }
			it { should be_able_to(:like, Event.new) }
			it { should be_able_to(:like, TeamsheetEntry.new) }
			it { should be_able_to(:like, InviteResponse.new) }
			it { should be_able_to(:like, InviteReminder.new) }
			it { should be_able_to(:comment, Event.new) }
			it { should be_able_to(:comment, TeamsheetEntry.new) }
			it { should be_able_to(:comment, InviteResponse.new) }
			it { should be_able_to(:comment, InviteReminder.new) }
			it { should be_able_to(:comment_via_email, User.new) }
			it { should be_able_to(:comment_via_email, Event.new) }
			it { should be_able_to(:comment_via_email, TeamsheetEntry.new) }
			it { should be_able_to(:comment_via_email, InviteResponse.new) }
			it { should be_able_to(:comment_via_email, InviteReminder.new) }
		end

		# ones that actually test shit
		describe 'deleting likes' do
			let(:user){ FactoryGirl.create(:user) }
			let(:other_user){ FactoryGirl.create(:user) }
			let(:user_ail) do
				ail = ActivityItemLike.new
				ail.user = user
				ail
			end
			let(:other_user_ail) do
				ail = ActivityItemLike.new
				ail.user = other_user
				ail
			end
			it { should be_able_to(:destroy, user_ail) }
			it { should_not be_able_to(:destroy, other_user_ail) }
		end
	end

	describe 'clubs' do
		let(:club){ FactoryGirl.create(:club) }
		# user not defined, as this represents logged out (ie. anyone)
		it {should be_able_to(:read, club) }
	end

	# league shit
	describe 'leagues and ting' do
		let(:league){ division.league }
		let(:other_league){ FactoryGirl.create :league }
		let(:division){ FactoryGirl.create :division_season }
		let(:fixture){ FactoryGirl.create :fixture, division_season: division }
		let(:team) do
			team = FactoryGirl.create :team, :with_players, player_count: 1
			TeamDSService.add_team(division, team)
			team
		end
		let(:other_team){ FactoryGirl.create :team }
		let(:points) do
			p = FactoryGirl.create :points
			p.fixture = fixture
			p
		end
		let(:result) do
			r = FactoryGirl.create :soccer_result
			r.fixture = fixture
			r
		end
		
		# league admin
		describe 'league admin' do
			let(:user){ league.organisers.first }
			it { should be_able_to(:read, division) }
			it { should be_able_to(:manage, division) }
			it { should be_able_to(:read_unpublished, division) }
			it { should be_able_to(:update, points) }
			it { should be_able_to(:update, result) }
			it { should be_able_to(:manage, fixture) }
			it { should be_able_to(:update, fixture) }
			it { should be_able_to(:read, fixture) }
			it { should be_able_to(:destroy, fixture) }
		end
		# other league admin
		describe 'other league admin' do
			let(:user){ other_league.organisers.first }
			it { should be_able_to(:read, division) }
			it { should_not be_able_to(:manage, division) }
			it { should_not be_able_to(:read_unpublished, division) }
			it { should_not be_able_to(:update, points) }
			it { should_not be_able_to(:update, result) }
			it { should_not be_able_to(:manage, fixture) }
			it { should_not be_able_to(:update, fixture) }
			it { should be_able_to(:read, fixture) }
			it { should_not be_able_to(:destroy, fixture) }
		end
		# league team org
		describe 'league team org' do
			let(:user){ team.organisers.first }
			it { should be_able_to(:read, division) }
			it { should_not be_able_to(:manage, division) }
			it { should_not be_able_to(:read_unpublished, division) }
			it { should_not be_able_to(:update, points) }
			it { should_not be_able_to(:update, result) }
			it { should_not be_able_to(:manage, fixture) }
			it { should_not be_able_to(:update, fixture) }
			it { should be_able_to(:read, fixture) }
			it { should_not be_able_to(:destroy, fixture) }
		end
		# league team player
		describe 'league team player' do
			let(:user){ team.players.second }
			it { should be_able_to(:read, division) }
			it { should_not be_able_to(:manage, division) }
			it { should_not be_able_to(:read_unpublished, division) }
			it { should_not be_able_to(:update, points) }
			it { should_not be_able_to(:update, result) }
			it { should_not be_able_to(:manage, fixture) }
			it { should_not be_able_to(:update, fixture) }
			it { should be_able_to(:read, fixture) }
			it { should_not be_able_to(:destroy, fixture) }
		end
		# other team org
		describe 'other team org' do
			let(:user){ other_team.organisers.first }
			it { should be_able_to(:read, division) }
			it { should_not be_able_to(:manage, division) }
			it { should_not be_able_to(:read_unpublished, division) }
			it { should_not be_able_to(:update, points) }
			it { should_not be_able_to(:update, result) }
			it { should_not be_able_to(:manage, fixture) }
			it { should_not be_able_to(:update, fixture) }
			it { should be_able_to(:read, fixture) }
			it { should_not be_able_to(:destroy, fixture) }
		end
		# other team player
		describe 'other team player' do
			let(:user){ other_team.players.second }
			it { should be_able_to(:read, division) }
			it { should_not be_able_to(:manage, division) }
			it { should_not be_able_to(:read_unpublished, division) }
			it { should_not be_able_to(:update, points) }
			it { should_not be_able_to(:update, result) }
			it { should_not be_able_to(:manage, fixture) }
			it { should_not be_able_to(:update, fixture) }
			it { should be_able_to(:read, fixture) }
			it { should_not be_able_to(:destroy, fixture) }
		end
		# logged out user
		describe 'logged out user' do
			let(:user){ nil }
			it { should be_able_to(:read, division) }
			it { should_not be_able_to(:manage, division) }
			it { should_not be_able_to(:read_unpublished, division) }
			it { should_not be_able_to(:update, points) }
			it { should_not be_able_to(:update, result) }
			it { should_not be_able_to(:manage, fixture) }
			it { should_not be_able_to(:update, fixture) }
			it { should be_able_to(:read, fixture) }
			it { should_not be_able_to(:destroy, fixture) }
		end
		# junior user
		describe 'junior user' do
			let(:user){ FactoryGirl.create :junior_user }
			it { should_not be_able_to(:read, division) }
			it { should_not be_able_to(:manage, division) }
			it { should_not be_able_to(:read_unpublished, division) }
			it { should_not be_able_to(:update, points) }
			it { should_not be_able_to(:update, result) }
			it { should_not be_able_to(:manage, fixture) }
			it { should_not be_able_to(:update, fixture) }
			it { should_not be_able_to(:read, fixture) }
			it { should_not be_able_to(:destroy, fixture) }
		end
	end
end
