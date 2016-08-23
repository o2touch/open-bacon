class Api::V1::Users::UserInvitationsController < Api::V1::ApplicationController

  def create
    ActiveRecord::Base.transaction do
      u_attrs = params[:user]
      raise InvalidParameter.new if u_attrs.nil? || u_attrs.empty?

      team = Team.find(params[:team_id])
      tenant = LandLord.new(team).tenant

      save_type = params[:save_type]
      raise InvalidParameter.new("save_type required") if save_type.nil?

      # create user
      user = User.find_by_email(u_attrs[:email]) unless u_attrs[:email].blank?
      user = User.find_by_mobile_number(u_attrs[:mobile_number]) if user.nil? && !u_attrs[:mobile_number].blank?
      user = create_user(u_attrs, save_type, tenant) if user.nil?

      # create junior, if required
      junior = nil
      if save_type == UserInvitationTypeEnum::LINKED_PARENT_JUNIOR
        # *****
        # This is FUCKING insanity, carried over from the previous implementation of this controller
        #  For some incomprehensible reason, an un-named former backend dev deemed it sensible to
        #  have an id attr sent on the user we're creating. That id, refers to that user's
        #  already existing child, to which it should be associated. Obvs. TS
        # **
        junior = User.find u_attrs[:id] if u_attrs.has_key? :id
        junior = create_junior(u_attrs, user, save_type, tenant) unless u_attrs.has_key? :id
      end

      # invite them to whatever they were being invited to
      process_invitation(user, junior, team, params)

      # grab the correct template
      if junior.nil?
        @user = user
        template = "api/v1/users/show"
      else
        @users = [junior, user]
        template = "api/v1/users/index"
      end

      # done and done
      render template: template, formats: [:json], handlers: [:rabl]
    end
  end

  private

  def create_user(attrs, save_type, tenant)
    user = User.create!({
      name: attrs[:parent_name] || attrs[:name],
      email: attrs[:email],
      mobile_number: attrs[:mobile_number],
      time_zone: current_user.time_zone,
      country: current_user.country,
      invited_by_source_user_id: current_user.id,
      invited_by_source: params[:save_type]
    })
    user.add_role RoleEnum::INVITED
    user.tenant = tenant
    user.configurable_set_parent(tenant)
    user.save!

    user
  end

  def create_junior(attrs, parent, save_type, tenant)
    junior = JuniorUser.new({
      name: attrs[:name],
      email: nil,
      mobile_number: nil,
      time_zone: parent.time_zone,
      country: parent.country,
      invited_by_source_user_id: current_user.id,
      invited_by_source: params[:save_type]
    })
    junior.tenant = tenant
    junior.configurable_set_parent(tenant)

    # match the roles
    junior.add_role RoleEnum::INVITED if parent.role? RoleEnum::INVITED
    junior.add_role RoleEnum::REGISTERED if parent.role? RoleEnum::REGISTERED
    
    junior
  end

  def process_invitation(user, junior, team, params)
    save_type = params[:save_type]

    # this metric is set here, as 
    metric_user = junior || user

    case save_type
    when UserInvitationTypeEnum::TEAM_FOLLOW
      team_follow(user, team, params)
    when UserInvitationTypeEnum::LINKED_PARENT_JUNIOR
      linked_parent_junior(user, junior, team, save_type)
    when UserInvitationTypeEnum::TEAM_PROFILE
      player_invite(user, team, save_type)
    when UserInvitationTypeEnum::EVENT
      player_invite(user, team, save_type)
    when UserInvitationTypeEnum::EVENT_CHECKIN
      event_checkin(user, team, save_type, params)
    else
      raise InvalidParameter.new "Invalid save_type"
    end
    
    team.goals.notify
  end

  def team_follow(user, team, save_type)
    authorize! :add_follower, team

    TeamUsersService.add_follower(team, user, current_user)
    AppEventService.create(user, current_user, "follower_invited", { team_id: team.id })

    platform = get_platform
  end 

  def linked_parent_junior(parent, junior, team, save_type)
    authorize! :manage_roster, team

    # join to parent
    junior.associate_parent(parent)

    TeamUsersService.add_parent(team, parent, true, current_user) # send invitation
    TeamUsersService.add_player(team, junior, false) unless team.players.include?(junior) # don't sent invitation 

    platform = get_platform
  end

  # ie normal invitation to team.
  def player_invite(user, team, save_type)
    authorize! :manage_roster, team

    TeamUsersService.add_player(team, user, true, current_user) # send invitation

    invite_type = (save_type == UserInvitationTypeEnum::EVENT) ? AddedToTeamEnum::EVENT_INVITED : AddedToTeamEnum::TEAM_INVITED

    platform = get_platform
  end

  # so o2 touch dickheads can register people, and check them in
  def event_checkin(user, team, save_type, params)
    authorize! :manage_roster, team

    event = Event.find(params[:event_id])
    tse = EventInvitesService.add_players(event, [user], send_pusher_update=true).first
    TeamsheetEntriesService.check_in(tse) unless tse.nil? # if they're in the team
    # invalidate the event cache, so user doesn't get added twice
    TeamUsersService.add_player(team, user, true, current_user, false) # send invitation

    platform = get_platform
  end



  # def create
  #   # make sure we get everything we need, else error
  #   team = Team.find(params[:team_id]) # with raise if not found

  #   # auth
  #   authorize! :add_follower, team if params[:save_type] == UserInvitationTypeEnum::TEAM_FOLLOW
  #   authorize! :manage_roster, team unless params[:save_type] == UserInvitationTypeEnum::TEAM_FOLLOW

  #   # if we're creating a parent and junior render the index
  #   if params[:save_type] == UserInvitationTypeEnum::LINKED_PARENT_JUNIOR
  #     raise InvalidParameter if params[:user].nil? || params[:user][:email].blank?
  #     resources = create_team_invitation(team, params[:user])
  #     @users = resources
  #     render template: "api/v1/users/index", formats: [:json], handlers: [:rabl]
  #   # else render show
  #   else
  #     raise InvalidParameter if params[:user].nil? || (params[:user][:email].blank? && params[:user][:mobile_number].blank?)
  #     resources = create_team_invitation(team, params[:user])
  #     @user = resources
  #     render template: "api/v1/users/show", formats: [:json], handlers: [:rabl]
  #   end
  # end
  
  # # both options above call this.
  # def create_team_invitation(team, attrs)
  #   # very shit validity check.
  #   raise InvalidParameter.new if attrs.nil?

  #   # see if the user already exists
  #   user = nil
  #   if attrs.has_key?(:email) && !attrs[:email].blank?
  #     user = User.find_by_email(attrs[:email]) 
  #   elsif attrs.has_key?(:mobile_number) && !attrs[:mobile_number].blank?
  #     user = User.find_by_mobile_number(attrs[:mobile_number])
  #   end
  #   junior = nil
  #   existing_junior = false

  #   tenant = LandLord.new(team).tenant

  #   ActiveRecord::Base.transaction do
  #     if user.nil?
  #       country = GeographicDataUtil.new().country_from_ip(request.remote_ip)
  #       time_zone = request.cookies['timezone']
  #       time_zone = TimeZoneEnum[0] if time_zone.nil?

  #       user = User.create!({
  #         name: attrs[:parent_name] || attrs[:name],
  #         email: attrs[:email],
  #         mobile_number: attrs[:mobile_number],
  #         time_zone: current_user.time_zone,
  #         country: country,
  #         invited_by_source_user_id: current_user.id,
  #         invited_by_source: params[:save_type]
  #       })
  #       user.add_role RoleEnum::INVITED

  #       user.tenant = tenant
  #       user.configurable_set_parent(tenant)
  #       user.save!
  
  #     end

  #     # if there's mean to be a junior, create that too
  #     if params[:save_type] == UserInvitationTypeEnum::LINKED_PARENT_JUNIOR
  #       junior = User.find_by_id(attrs[:id])

  #       if junior.nil?
  #         junior = JuniorUser.new({
  #           name: attrs[:name],
  #           email: nil,
  #           mobile_number: nil,
  #           time_zone: user.time_zone,
  #           country: user.country,
  #           invited_by_source_user_id: current_user.id,
  #           invited_by_source: params[:save_type]
  #         })
  #         # match the roles
  #         junior.add_role RoleEnum::INVITED if user.role? RoleEnum::INVITED
  #         junior.add_role RoleEnum::REGISTERED if user.role? RoleEnum::REGISTERED

  #         junior.tenant = tenant
  #         junior.configurable_set_parent(tenant)
  #         junior.save!
  #       else
  #         existing_junior = true
  #       end

  #       junior.associate_parent(user)
  #       junior.save!
  #       user.reload
  #     end
  #   end

  #   # now add the junior as a parent
  #   if !junior.nil?
  #     TeamUsersService.add_parent(team, user, true, current_user) # send invitation
  #     unless existing_junior
  #       TeamUsersService.add_player(team, junior, false)  # don't sent invitation 
  #       team.goals.notify
  #     end

  #     return [junior, user]
  #   # or if it's a  normal user add it to ting
  #   else
  #     if params[:save_type] == UserInvitationTypeEnum::TEAM_FOLLOW
  #       TeamUsersService.add_follower(team, user, current_user)
  #       AppEventService.create(user, current_user, "follower_invited", { team_id: team.id })
  #     else
  #       TeamUsersService.add_player(team, user, true, current_user) # send invitation
  #       team.goals.notify
  #     end

  #     return user
  #   end
  # end

end