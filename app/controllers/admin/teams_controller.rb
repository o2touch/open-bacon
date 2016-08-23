class Admin::TeamsController < Admin::AdminController

  def index
    @teams = Team.all;
  end

  # GET /admin/teams/1
  # GET /admin/teams/1.json
  def show
    @team = Team.find(params[:id])

    # Statistics
    @active_players = @team.active_players

    @percent_active = 0
    if @team.players.size > 0
      @percent_active = (@active_players.size.to_f / @team.players.size.to_f * 100).round
    end

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @team }
    end
  end

  # GET /admin/teams/new
  # GET /admin/teams/new.json
  def new
    @team = Team.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @team }
    end
  end

  # GET /admin/teams/1/edit
  def edit
    @team = Team.find(params[:id])
  end

  # PUT /admin/teams/1
  # PUT /admin/teams/1.json
  def update
    @team = Team.find(params[:id])

    respond_to do |format|
      if @team.update_attributes(params[:team])
        format.html { redirect_to @team, notice: 'Team was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @team.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def destroy
    t = Team.find(params[:id])
    t.delete
    
    redirect_to admin_teams_path, :notice => "Team deleted successfully"
  end

  def remove_player
    t = Team.find(params[:team_id])
    u = User.find(params[:user_id])

    if TeamUsersService.remove_player_from_team(t, u)
      redirect_to [:admin, t], :notice => "User '#{u.name}' removed from team"
    else
      redirect_to [:admin, t], :notice => "Can not remove player"
    end
        
  end

  def remove_organiser_role
    t = Team.find(params[:team_id])
    u = User.find(params[:user_id])

    if TeamUsersService.remove_organiser_from_team(t, u)
      redirect_to [:admin, t], :notice => "User '#{u.name}' removed"
    else
      redirect_to [:admin, t], :notice => "Can not remove last organiser"
    end
        
  end

  def refresh_team_roles_cache
    t = Team.find(params[:team_id])
    t.team_roles_last_updated_at=Time.now
    t.save

    redirect_to [:admin, t], :notice => "Team Roles cache updated"
  end
  
end