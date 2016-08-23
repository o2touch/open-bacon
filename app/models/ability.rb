class Ability
  include CanCan::Ability

  def initialize(user)

    # This if-else block essentially provides the structure of how bf roles, 
    # and their related permissions, fit toghether.
    # NO_LOGIN overides all else and gives nothing. Assuming the absence of that
    # role we test for the presence (or not) of all other roles and add sets of
    # permissions accordingly.
    #
    # Although roles are not actually mutually exclusive, in practice no user
    # should have INVITED && (REGISTERD || JUNIOR || ADMIN), so I added the nested
    # to ensure if it accidentally happens, bad things still can't happen.
    #
    # If a user has permissions that contradict each other (ie registered 
    # has a can, and junior has an equivalent cannot) the last one takes presidence.
    # However, if there are two cans for the same permisions, their conditions are 
    # logically or'ed.
    #
    # TS

    user ||= User.new # logged out user

    if user.role? RoleEnum::NO_LOGIN # no_login overides everything.
      no_login(user)
    # special faft user
    elsif user.role? RoleEnum::FAFT_ROBOT
      faft_robot(user)
    # logged out user  
    elsif user.roles.count == 0 
      any_one(user)
      logged_out(user) 
    # logged in user
    else 
      any_one(user)
      any_logged_in(user)

      if user.role? RoleEnum::INVITED
        invited(user)
      elsif user.role? RoleEnum::REGISTERED
        any_registered(user)
        registered_junior(user) if user.role? RoleEnum::JUNIOR
        registered_adult(user) unless user.role? RoleEnum::JUNIOR
        admin(user) if user.role? RoleEnum::ADMIN
      end
    end

    # include_all(user)
    # include_logged_out(user)
    # any_logged_in
    # invited

    # Registered.roles || Invited.roles || Junior.roles || Login.roles || Blocked
    #
    #
  end

  # perms for the faft robot. we should limit it to just what it needs, and
  #   only on objects generated from faft, just in case...
  def faft_robot(user)
  end

  # perms for admins
  def admin(user)
    # change to read everything, instead of manage everything...
    can :read, :all
    can :read_private_details, :all
    can :view_private_details, :all
    can :view, :all
    can :read_unpublished, :all
    # and destroy a couple o' ting
    can :delete, User
    can :delete, Team

    can :read_reports, Tenant
  end
  

  # perms for any logged in user
  def any_logged_in(user)
    can :export_calendar, User do |user_check|
      user.id == user_check.id || can?(:act_on_behalf_of, user_check)
    end

    # only matters if read in any_one() is false (ie. user_check is junior)
    can :read, User do |user_check| 
      user.id == user_check.id || can?(:act_on_behalf_of, user_check) || user.friends.include?(user_check) || admin_of_users_league?(user, user_check)
    end

    # contact details and shit
    can :read_private_details, User do |user_check|
      user.id == user_check.id || can?(:act_on_behalf_of, user_check) || admin_of_users_team?(user, user_check) || admin_of_users_league?(user, user_check)
    end

    # ie parent
    can :act_on_behalf_of, User do |user_check|
      user_check.junior? && user_check.parent_ids.include?(user.id)
    end

    # TEAM
    can :read, Team do |team|
      team.has_member?(user) || team.primary_league.has_organiser?(user) || can?(:manage_teams, team.tenant)
    end

    # currently only used for mobile app, prob should use on web too. TS
    can :read_private_details, Team  do |team|
      team.has_member?(user) || (!team.primary_league.nil? && team.primary_league.has_organiser?(user))
    end

    can :export_calendar, Team do |team|
      team.has_member?(user)
    end

    # Not sure these should be here... Can be inferred from other info (eg. are they in the team)
    #  also, they're more about whether it is feasible, rather than whether they're allowed
    #  Plus, this is checking the team, and the setting belong to the user. We should just be
    #  looking for the settings (if has perms to edit user), and raise invalid id not there. TS
    can :read_notification_settings, Team do |team|
      team.has_associate?(user)
    end
    can :update_notification_settings, Team do |team|
      team.has_associate?(user) 
    end

    # EVENT
    # only matters is read in any_one gives false
    can :read, Event do |event|
      # organiser, player, player parent, or team organiser
      event.user_id == user.id || event.is_invited?(user) || user.child_invited_to?(event) || can?(:manage, event.team)
    end

    can :read_messages, Event do |event|
      # organiser, player, player parent, or team organiser
      event.user_id == user.id || event.is_invited?(user) || user.child_invited_to?(event) || can?(:manage, event.team)
    end

    # TODO: remove in favour of :read_private_details
    can :read_all_details, Event do |event|
      can? :read_private_details, Event
    end

    # TODO: remove in favour of :read_private_details
    can :view_private_details, Event do |event|
      can? :read_private_details, Event
    end

    can :read_private_details, Event do |event|
      # organiser, player, player parent, or team organiser
      event.user_id == user.id || event.is_invited?(user) || user.child_invited_to?(event) || can?(:manage, event.team)
    end

    # SR: Added to mimic
    can :view_private_details, DivisionSeason do |division|
      division.league.has_organiser?(user)
    end

    # SR: Added to mimic
    can :read_private_details, DivisionSeason do |division|
      division.league.has_organiser?(user)
    end

    # DEPRECATED: this is only used for view code, not actual authorisation, so should be removed from here. TS.
    can :respond_to_invite, Event do |event|
      event.teamsheet_entries.map{|tse| tse.user_id}.include?(user.id) && event.user_id != user.id
    end

    can :respond, TeamsheetEntry do |tse|
      # player, event organiser (legacy), parent, or team organiser
      #tse.event.team.has_associate?(user) &&
      (user.id == tse.user_id || tse.event.user_id == user.id || can?(:act_on_behalf_of, tse.user) || can?(:manage, tse.event.team))
    end

    can :check_in, TeamsheetEntry do |tse|
      can? :manage_roster, tse.event.team
    end

    # ACTIVITY ITEMS
    can :view, ActivityItem

    can :create_message_via_email, Event do |event|
      # organiser, or registered player
      # TODO: generalise this set of perms (and refactor to check user has role on team)
      event.user_id == user.id || event.is_invited?(user) || user.child_invited_to?(event) || can?(:manage, event.team)
    end

    # ACTIVITY ITEM COMMENTS AND LIKES
    can :comment_via_email, EventMessage do |message| 
      # if this implementation changes then a test is required
      if message.messageable.is_a? Team 
        message.messageable.has_active_member?(user)
      elsif message.messageable.is_a? Event
        can? :create_message_via_email, message.messageable
      end 
    end

    can :comment_via_email, EventResult do |event_result|
      # if this implementation changes then a test is required
      can? :create_message_via_email, event_result.event 
    end

    can :comment_via_email, User
    can :comment_via_email, Event 
    can :comment_via_email, TeamsheetEntry 
    can :comment_via_email, InviteResponse
    can :comment_via_email, InviteReminder
  end
  

  # perms for anyone, including logged out. 
  # (Though not inluding NO_LOGIN, but by definition they would end up being logged_out users.)
  def any_one(user)
    # anyone can read a league
    can :read, League
    can :read, DivisionSeason
    can :read, Fixture
    can :read, Location
    can :read, Club
    
    # EVENT
    can :read, Event do |event|
      # nil tests in case old shit in db.
      event.team == nil || event.team.profile == nil || event.team.profile.age_group > AgeGroupEnum::UNDER_13
    end

    # TEAM
    can :follow, Team do |team|
      team.config.team_followable == true
    end

    can :join_as_player, Team do |team|
      team.config.team_joinable == true
    end

    # deprecated only required for Mobile app versions <= 1.3
    can :follow_faft_team, Team # ain't no ting to test on...

    can :view_public_profile, Team do |team|
      team.is_public?
    end
  end
  

  # perms that any registered user has
  def any_registered(user)
    # juniors can't do anything, so it's all currently in registered adult
  end
  

  # for invited users
  def invited(user)
    # put perms here that are for invited users ONLY!
    # if registered users can also do it, put the perm in any_logged_in
    can :confirm, User do |u|
      u == user
    end

    can :update, User do |user_check|
      #this is used to allow invited users leave teams.
      user == user_check 
    end
  end
  

  # for people that shouldn't be able to log in
  def no_login(user)
    # nada
  end
  

  # perms for registered adult (ie, with REGISTERED and without JUNIOR)
  def registered_adult(user)
    # TENANT
    can :manage, Tenant do |t|
      t.organisers.include? user
    end

    can :read_reports, Tenant do |t|
      # TODO: put per tenant shit here (prob by checking tenant config)
      can? :manage, t
    end

    can :read_dashboard, Tenant do |t|
      # TODO: put per tenant shit here (prob by checking tenant config)
      can? :manage, t
    end

    can :create_tenanted_league, Tenant do |t|
      # TODO: put per tenant shit here (prob by checking tenant config)
      can? :manage, t
    end

    can :manage_leagues do |t|
      # TODO: put per tenant shit here (prob by checking tenant config)
      can? :manage, t
    end

    can :manage_teams, Tenant do |t|
      # TODO: put per tenant shit here (prob by checking tenant config)
      can? :manage, t
    end

    # LEAGUE
    can :manage, League do |l|
      l.has_organiser?(user) || can?(:manage_leagues, l.tenant)
    end
    
    # DIVISION
    can :manage, DivisionSeason do |div|
      can? :manage, div.league
    end

    can :read_unpublished, DivisionSeason do |div|
      can? :manage, div.league
    end

    can :add_team, DivisionSeason do |ds|
      ds.config.applications_open
    end

    # FIXTURE
    can :manage, Fixture do |fx|
      can? :manage, fx.division_season
    end

    # RESULT
    can :update, Result do |r|
      can? :manage, r.fixture
    end

    # POINTS
    can :update, Points do |p|
      can? :manage, p.fixture
    end

    can :update, User do |user_check|

      can_update = false

      if (user == user_check || can?(:act_on_behalf_of, user_check) || admin_of_users_league?(user, user_check))
        can_update = true

      elsif user_check.role?(RoleEnum::INVITED)
        #SR - there is a problem in that a user could be invited dto multiple teams and an organiser could update
        #their details and the update would be seen across all teams!
        can_update = (user_check.team_roles.map(&:obj_id) & user.teams_as_organiser_ids).count > 0
      end

      can_update
    end

    can :update, DemoUser do |user_check|
      user == user_check 
    end 

    # TEAM
    can :create, Team

    can :create_o2_touch_team, Team do |team|
      # true
      user.teams_as_organiser.select{|t| t.tenant_id == TenantEnum::O2_TOUCH_ID }.count > 0
    end

    can :create_mitoo_team, Team

    can :create_alien_team, Team do |team|
      false
    end

    can :create_soccer_sixes_team, Team do |team|
      false
    end

    can :update, Team do |team|
      team.has_organiser?(user)
    end

    # including creating events
    can :manage, Team do |team|
      # nil check, so we can chain the abilites together, without nil checks everywhere
      team != nil && (team.has_organiser?(user) || can?(:manage_teams, team.tenant))
    end

    can :manage_roster, Team do |team|
                              # change LMR settings to use new config  # need a better method name here...
      can?(:manage, team) || (team.league_managed_roster? && team.user_is_primary_league_admin?(user)) 
    end

    can :add_follower, Team do |team|
      team.config.team_followable && team.has_associate?(user)
    end

    can :become_faft_organiser, Team do |team|
      team.faft_team? && team.organisers.count == 0 && team.has_follower?(user)
    end

    can :delete, PolyRole do |poly_role|
      if poly_role.obj.is_a? Team
        if poly_role.user_id == user.id
          poly_role.role_id == PolyRole::FOLLOWER
        else
          can? :manage_roster, poly_role.obj #team
        end
      else
        false
      end
    end

    can :create_message, Team do |team|
      team.has_active_member?(user)
    end

    can :view_public_profile, Team do |team|
      team.has_follower?(user)
    end

    # EVENT
    can :create, Event if user.teams_as_organiser.count > 0

    # nb. This ability duplicated (for app speed) in event_json_helper.rb, so make
    #     any edits there aswell! TS.
    can :manage_event, Event do |event|
      # organiser, or registered team organiser
      if !event.fixture.nil?
        false #abitshit ie. won't work once fixtures are used outside of leagues. TS
      else
        event.user_id == user.id || can?(:manage, event.team)
      end
    end

    can :manage_event, DemoEvent do |event|
      # organiser, or registered team organiser
      event.user_id == user.id || can?(:manage, event.team)
    end
      
    can :send_invites, Event do |event|
      # registered event or team organiser
      event.user_id == user.id || can?(:manage, event.team)
    end
    
    can :create_message, Event do |event|
      # organiser, or registered player
      # TODO: generalise this set of perms (and refactor to check user has role on team)
      #event.team.has_associate?(user) &&
      (event.user_id == user.id || event.is_invited?(user) || user.child_invited_to?(event) || can?(:manage, event.team))
    end

    can :create_message, DivisionSeason do |div|
      # TODO: This is very slow
      div.league.has_organiser? user
    end

    # ACTIVITY ITEM COMMENTS AND LIKES
    can :comment, EventMessage do |message| 
      # if this implementation changes then a test is required
      if message.messageable.is_a? Team 
        team = message.messageable
        team.has_active_member?(user)
      elsif message.messageable.is_a? Event
        can? :create_message, message.messageable
      end 
    end

    can :like, EventMessage do |message| 
      # if this implementation changes then a test is required
      can? :comment, message
    end

    can :comment, EventResult do |event_result|
      # if this implementation changes then a test is required
      can? :create_message, event_result.event 
    end
    can :like, EventResult do |event_result|
      # if this implementation changes then a test is required
      can? :create_message, event_result.event 
    end

    #SR - NEED TO FIX ALL OF THIS
    can [:like, :comment], [InviteResponse, InviteReminder] do |obj|
      #obj.teamsheet_entry.event.team.has_active_member?(user)
      true
    end
    
    can [:like, :comment], Event do |event|
      #event.team.has_active_member?(user)
      true
    end

    can [:like, :comment], TeamsheetEntry do |tse|
      #tse.event.team.has_active_member?(user)
      true
    end

    can :destroy, ActivityItemLike do |like|
      user == like.user
    end

    can :update, ActivityItem do |ai|
      #Currently we can only update EventMessage items. 
      #Premissions around ActivityItem objs are a bit tricky however for now
      #it makes sense to check if the current user can update the 'obj'.

      if ai.obj_type == EventMessage.name
        #SR We want to check that the user can manage a team but I am not going to implement,
        #this check until we have a nice way to extract this information. 
        #I am currently checking in or manage team directly in the controller
      else
        false
      end
    end
  end
  

  # perms only for registered junior (ie. with REGISTERED and JUNIOR)
  def registered_junior(user)
    # put perms here that ONLY juniors should be able to do
    # if adult can also do it, put it is any_registered
  end


  # perms for logged out users ONLY
  def logged_out(user)
    # put perms here that are for logged out users ONLY.
    # if any one should have this perm put it in any_one

    # TEAM
    # logged out users (only) can create a team, but only through one
    # specific action (teams#guest_create).
    can :guest_create, Team
    can :guest_update, Team do |team|
      team.founder.nil?
    end

    # used when a logged out user has created a team, just before they register
    #   and in doing so should become that teams organiser
    can :become_organiser, Team do |team|
      team.founder.nil?
    end
  end

  private
  # helper methods here:
  def admin_of_users_league?(league_org, user_check)
    ltt_ids = user_check.leagues_through_teams.map(&:id)
    lao_ids = league_org.leagues_as_organiser.map(&:id)

  can_update = (ltt_ids & lao_ids).count > 0
  end

  def admin_of_users_team?(team_org, user_check)
    user_teams = user_check.cached_team_roles.map(&:obj_id)
    admin_teams_as_org = team_org.cached_team_roles.select{|tr| tr.role_id == 2 }.map(&:obj_id)

    (user_teams & admin_teams_as_org).size > 0
  end
end