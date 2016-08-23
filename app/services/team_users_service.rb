class TeamRoleError < StandardError; end
class ExistingRoleError < StandardError; end

class TeamUsersService
  SEMAPHORE = Mutex.new

  class << self

    def migrate_user_to_role(user, team, role)
      role = role.to_i
      if team.junior?
        case role
        when 0 then
          TeamUsersService.remove_member_from_team(team, user)
        end
      end

      if !team.junior?
        if team.has_organiser?(user)
          case role
          when PolyRole::PLAYER 
            TeamUsersService.remove_organiser_from_team(team, user)  
            #alrady a player          
          when PolyRole::FOLLOWER
            TeamUsersService.remove_organiser_from_team(team, user)            
            TeamUsersService.remove_player_from_team(team, user)
            TeamUsersService.add_follower(team, user)
          when 0 then
            TeamUsersService.remove_organiser_from_team(team, user)
            TeamUsersService.remove_player_from_team(team, user)
            TeamUsersService.remove_member_from_team(team, user)
          end
        elsif team.has_player?(user)
          case role
          when PolyRole::FOLLOWER
            TeamUsersService.remove_player_from_team(team, user)
            TeamUsersService.add_follower(team, user)
          when 0 then
            TeamUsersService.remove_player_from_team(team, user)
            TeamUsersService.remove_member_from_team(team, user)
          end
        elsif team.has_follower?(user)
          case role
          when 0 then
            TeamUsersService.remove_member_from_team(team, user)
          end
        end
      end
    end

    def add_parent(team, parent, invite_to_team, by_user=nil)
      raise Exception if parent.junior?
      raise TeamRoleError.new("You must specify by_user") if invite_to_team && by_user.nil? 

      # Add team role
      team_role = team.add_parent(parent)

      # Create TeamInvite
      create_team_invite(team, parent, by_user, true) if invite_to_team==true

      # update the user's tenant id to reflect their new team roles
      update_user_tenant_id(parent)

      team_role
    end

    def add_organiser(team, user, delay_processing=true)
      #Supports follower -> organiser + player
      #Supports player -> organiser
      if team.has_organiser?(user)
        raise ExistingRoleError.new("User is already an organiser of the team")
      end

      if user.junior?
        raise TeamRoleError.new "Cannot add a junior as an organiser"
      end

      if team.faft_team?
        if user.faft_teams_as_organiser.count >= MAX_FAFT_TEAMS_ORGANISING
          raise TeamRoleError.new "Can not become the organiser of so many faft teams" 
        end 
      end

      team.remove_follower(user)
      team_role = team.add_organiser(user)
      team.organisers(true)
      
      if !team.junior? 
        begin 
          TeamUsersService.add_player(team, user, false, nil, delay_processing)
        rescue
          #this can fail if the user is already a player or you try to add an adult to a junior team
          #we dont care and dont want to repeat checks here.
        end
      end

      if team.founder.nil?
        team.created_by = user
        team.save!
      end

      # update the user's tenant id to reflect their new team roles
      update_user_tenant_id(user)

      team_role
    end

    def add_player(team, player, invite_to_team, by_user=nil, delay_processing=true)
      if invite_to_team && by_user.nil? 
        raise TeamRoleError.new("You must specify by_user") 
      end

      if team.has_player?(player)
        raise ExistingRoleError.new "User is already a player in the team" 
      end

      unless TeamInvitePolicy.new(team).can_invite?(player)
        raise TeamRoleError.new "Cannot add a junior player to an adult team or vice versa" 
      end

      team.remove_follower(player)
      team_role = team.add_player(player)
    
      #Add user to all future events
      team.future_events.each do |e|
        if delay_processing
          AddPlayerToEventWorker.perform_async(e.id, player.id, true)
        else
          AddPlayerToEventWorker.new.perform(e, player, true)
        end
      end
      
      #Create TeamInvite
      if invite_to_team == true
        create_team_invite(team, player, by_user, true)
      end

      # update the user's tenant id to reflect their new team roles
      update_user_tenant_id(player)

      team_role
    end

    def add_follower(team, user, inviter=nil)
      if user.nil? || user.junior?
        raise TeamRoleError.new("You must specify an adult user") 
      end
      
      raise ExistingRoleError.new if team.has_associate?(user)

      inviter = user if inviter.nil?

      team_role = team.add_follower(user)
      create_team_invite(team, user, inviter, false)

      # update the user's tenant id to reflect their new team roles
      update_user_tenant_id(user)

      team_role
    end

###################### REMOVE MEMBERS FROM A TEAM

    def remove_player(team, player)
      # Remove from all future events
       team.future_events.each do |e|
        EventInvitesService.remove_player(e, player)
      end
    end

    def remove_player_from_team(team, player)
      if !team.has_player?(player)
        raise TeamRoleError.new("User is not an player of the team")
      end

      # Remove from all future events
      team.future_events.each do |e|
        EventInvitesService.remove_player(e, player)
      end

      team.remove_player(player)

      # update the user's tenant id to reflect their new team roles
      update_user_tenant_id(player)
    end

    def remove_parent_from_team(team, parent)
      if !team.has_parent?(parent)
        raise TeamRoleError.new("User is not a parent in the team")
      end

      team.remove_parent(parent)

      # update the user's tenant id to reflect their new team roles
      update_user_tenant_id(parent)
    end

    def remove_follower_from_team(team, follower)
      if !team.has_follower?(follower)
        raise TeamRoleError.new("User is not an follower of the team")
      end

      self.remove_member_from_team(team, follower) #SR - I DONT THINK THIS IS CORRECT!
    end

    def remove_organiser_from_team(team, organiser)
      if !team.has_organiser?(organiser)
        raise TeamRoleError.new("User is not an organiser of the team")
      end

      TeamUsersService::SEMAPHORE.synchronize do
        if team.organisers.count > 1 || (team.organisers.count == 1 && team.associates.count == 1)
          team.remove_organiser(organiser)        
        else
          raise TeamRoleError.new("Must create a new organiser before removing the last organiser in the team")
        end
      end

      # update the user's tenant id to reflect their new team roles
      update_user_tenant_id(organiser)
    end

    # Compleatly destroy all team roles and team invites
    def remove_member_from_team(team, member)

      # Remove roles
      PolyRole.destroy_all(user_id: member.id, obj_type: "Team", obj_id: team.id)
      team.team_roles_last_updated_at=Time.now
      team.save

      # Remove team invites
      TeamInvite.destroy_all(:sent_to_id => member.id, :team_id => team.id)

      # update the user's tenant id to reflect their new team roles
      update_user_tenant_id(member)

      team.reload
    end

    def get_user_invite(team_or_id, user)
      team_id = team_or_id.respond_to?(:id) ? team_or_id.id : team_or_id
      TeamInvite.find(:first, conditions: { team_id: team_id, sent_to_id: user.id })
    end

    private
    
    def create_team_invite(team, user, by_user=nil, notify)
      #Don't call this outside this class
      #Only want one invite
      return if team.team_invites.where(:sent_to_id => user.id).size > 0

      ti = TeamInvite.create({
        :sent_to => user,
        :sent_by => by_user,
        :team_id => team.id
      })
      ti.save
      team.team_invites << ti
      team.save

      if notify
        EmailNotificationService.notify_team_invite_created(ti, by_user) 
      end
    end

    # update the user's tenant id to reflect their new team roles
    def update_user_tenant_id(user)
      # set user tenant based on team roles
      begin
        user.reload
        tenant_ids = user.team_roles.map(&:obj).map(&:tenant_id).uniq

        tenant = LandLord.default_tenant if tenant_ids.size != 1
        tenant = LandLord.new(tenant_ids[0]).tenant if tenant_ids.size == 1

        user.tenant = tenant
        user.configurable_set_parent(tenant)
        user.save
      rescue
        #giveashit
        # (this is untested, in a rush, and I definitely don't want to break things! TS)
      end
    end
  end
end