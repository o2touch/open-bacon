class InvalidParameter < StandardError; end;

class UserRegistrationsService
  class << self
    def complete_registration(user, save_type, params)
      return false if user.nil? || save_type.nil?

      case save_type
      when UserInvitationTypeEnum::NORMAL
        normal(user, params)
      when "SIGNUPFLOW" # front end seems to send this instead of NORMAL
        normal(user, params)
      when UserInvitationTypeEnum::FACEBOOK
        facebook(user, params)
      when UserInvitationTypeEnum::CONFIRM_USER
        confirm(user, params)
      when UserInvitationTypeEnum::TEAM_OPEN_INVITE_LINK
        team_open_invite(user, params)
      when UserInvitationTypeEnum::TEAM_FOLLOW
        team_follow(user, params)
      when UserInvitationTypeEnum::JOIN_EVENT
        join_event(user, params)
      when UserInvitationTypeEnum::USER
        user(user, params)
      when UserInvitationTypeEnum::USER_CLAIM_LEAGUE
        user_claim_league(user, params)
      else
        raise Api::V1::ApplicationController::InvalidParameter.new "Invalid save_type"
      end

      user.add_role(RoleEnum::REGISTERED)
      user.delete_role(RoleEnum::INVITED)

      true
    end

    private

    # new organiser signup
    def normal(user, params)
      team = Team.find_by_uuid(params['team_uuid'])
      raise Api::V1::ApplicationController::InvalidParameter.new "invalid team uuid" if team.nil?
      Ability.new(user).authorize! :become_organiser, team 

      team.created_by_id = user.id
      TeamUsersService.add_organiser(team, user)
      team.goals.notify

      t = LandLord.mitoo_tenant
      user.tenant = t
      user.configurable_set_parent(t)
      user.save!

    end

    # add a user, and do nothing
    def user(user, params)
      tenant = LandLord.new(params[:tenant_id]).tenant if params.has_key? :tenant_id
      tenant = LandLord.default_tenant unless params.has_key? :tenant_id

      user.tenant = tenant
      user.configurable_set_parent(tenant)
      user.save!

    end

    # To catch dickheads that sign up throuh a login link
    def facebook(user, params)
      t = LandLord.mitoo_tenant
      user.tenant = t
      user.configurable_set_parent(t)
      user.save!

    end


    # player (or parent) confirming their account
    def confirm(user, params)
      Ability.new(user).authorize! :confirm, user 
      
      # update password if they gave us one
      if !params[:user].nil?
        user.update_attributes!(
          name: params[:user][:name],
          email: params[:user][:email],
          password: params[:user][:password],
          password_confirmation: params[:user][:password]
        )
      end

      # TODO: Move this to User Model/Service
      # also add roles for any children.
      user.children.each do |child|
        child.delete_role(RoleEnum::INVITED) 
        child.add_role(RoleEnum::REGISTERED) 
      end

      EventNotificationService.invited_user_registered(user)
    end

    # player signing up through team open invite link
    def team_open_invite(user, params)
      team = Team.find(params['team_id'])
      token = PowerToken.find_active_token(params['token'])
      # check that the token belongs to the correct team #abitshit
      #  PowerToken could do with a refactor to include a way to get back to the team TS
      if token.nil? || !token.token_matches?(team.open_invite_link.split("/").last)
        raise Api::V1::ApplicationController::InvalidParameter.new "Invalid token" 
      end

      TeamUsersService.add_player(team, user, false)

      t = LandLord.new(team).tenant
      user.tenant = t
      user.configurable_set_parent(t)

      user.time_zone = team.founder.time_zone
      user.save!
      team.goals.notify

      platform = PlatformHelper.get_platform_from_params(params)
    end

    # follower registered
    def team_follow(user, params)
      team = Team.find(params['team_id'])
      Ability.new(user).authorize! :follow, team

      t = LandLord.new(team).tenant
      user.tenant = t
      user.configurable_set_parent(t)
      user.save!
      
      TeamUsersService.add_follower(team, user)
      
      AppEventService.create(user, user, "follower_registered", { team_id: team.id} )

      platform = PlatformHelper.get_platform_from_params(params)
    end

    # Used in User Claim League Flow
    # add a user, and do nothing
    # TODO: Implement a different flow for claiming leagues
    def user_claim_league(user, params)
      tenant = LandLord.new(params[:tenant_id]).tenant if params.has_key? :tenant_id
      tenant = LandLord.default_tenant unless params.has_key? :tenant_id

      user.tenant = tenant
      user.configurable_set_parent(tenant)
      user.save!

    end

    # THIS IS ALL O2 TOUCH SPECIFIC
    # It can (and should) be generalised, but if that's done it needs to be taken all
    #  the way through to notifications.
    def join_event(user, params)
      event = Event.find(params[:event_id])
      team = event.team
      Ability.new(user).authorize! :join_as_player, team

      role = TeamUsersService.add_player(team, user, false, nil, false)

      # TODO: Move this elsewhere, and generalize it.
      t = LandLord.o2_touch_tenant
      user.tenant = t
      user.configurable_set_parent(t)
      user.save!

      # SHITTY HACK for users that sign in with facebook (but we fake it)
      if params[:user].has_key? :authorization
        user.authorizations.create({
          token: params[:user][:authorization][:token],
          uid: params[:user][:authorization][:uid],
          provider: 'Facebook',
          name: user.name
        })
      end


      platform = PlatformHelper.get_platform_from_params(params)

      md = { event_id: event.id, team_id: team.id, processor: 'Ns2::Processors::TeamRolesProcessor' }
      AppEventService.create(role, user, "created", md)
    end
  end
end