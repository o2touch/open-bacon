# TODO: Change this to PolyRoles, and have all kinds of roles hit this end point. 
#        May add complexity though. TS
class Api::V1::TeamRolesController < Api::V1::ApplicationController
  skip_before_filter :authenticate_user!, only: [:create_faft_follower]
  skip_authorization_check only: [:create, :create_faft_follower]

  def destroy
    @team_role = PolyRole.find(params[:id])
    authorize! :delete, @team_role

    @user = @team_role.user
    @team = @team_role.obj
    @role = @team_role.role_id

    #Prevent the user removing parents before children
    if @team_role.role_id == PolyRole::PARENT && @user.children.any? { |x| @team.has_member? x }
      render :json => { :errors => ['Remove the users children from the team first.'] }, 
        :status => :precondition_failed and return
    end

    ActiveRecord::Base.transaction do    
      case @role
        when PolyRole::PLAYER then TeamUsersService.remove_player_from_team(@team, @user)
        when PolyRole::FOLLOWER then TeamUsersService.remove_follower_from_team(@team, @user)
        when PolyRole::ORGANISER then TeamUsersService.remove_organiser_from_team(@team, @user)
        when PolyRole::PARENT then TeamUsersService.remove_parent_from_team(@team, @user)
      else
        raise InvalidParameter.new('Bad role')
      end
    end

    @team.goals.notify
    EmailNotificationService.notify_destroyed_team_role(@team_role, current_user)

    head :no_content
  end

  def create
    @role = params[:team_role][:role_id].to_i
    @team = Team.find(params[:team_role][:team_id])
    @user = User.find(params[:team_role][:user_id])

    if @role == PolyRole::FOLLOWER 
      authorize! :follow, @team if @user == current_user
      authorize! :add_follower, @team unless @user == current_user
      raise ExistingRoleError.new('Cannot follow a team you are part of') if @team.has_associate? @user
    elsif @team.faft_team? && @role == PolyRole::ORGANISER
      authorize!(:become_faft_organiser, @team)
    else
      # TODO: add this perm: complexity is generalizing the solution
      authorize!(:join_as_player, @team) if @user == current_user
      authorize!(:manage_roster, @team) unless @user == current_user
    end
    
    @team_role = nil

    ActiveRecord::Base.transaction do    
      case @role
        when PolyRole::ORGANISER then @team_role = TeamUsersService.add_organiser(@team, @user)
        when PolyRole::FOLLOWER then @team_role = TeamUsersService.add_follower(@team, @user, current_user)
        when PolyRole::PLAYER then @team_role = TeamUsersService.add_player(@team, @user, true, current_user)
      else
        raise InvalidParameter.new('Bad role')
      end

      @team.goals.notify

      EmailNotificationService.notify_created_team_role(@team_role, current_user)

      md = { processor: 'Ns2::Processors::TeamRolesProcessor' } # as using poly roles now, innit.
      AppEventService.create(@team_role, current_user, "created", md) if @role == PolyRole::FOLLOWER
    end

    @poly_role = @team_role # change in template...
    render 'api/v1/poly_roles/show', formats: [:json], status: :ok
  end
end
