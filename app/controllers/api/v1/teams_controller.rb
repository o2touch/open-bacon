class Api::V1::TeamsController < Api::V1::ApplicationController
	skip_authorization_check only: [:destroy, :index]
	skip_before_filter :authenticate_user!, only: [:show, :guest_create, :guest_update, :index]

	def index
    template = 'index'

    # just fetch a bunch of ids
    if params.has_key? :ids
      # just in case people request 1000000000 teams in due course...
      raise InvalidParameter.new("Too many teams requested") if params[:ids].count > 200
      # needs to not throw, and find_by_xxx doesn't support arrays...
      @teams = params[:ids].map{ |id| Team.find_by_id(id) }

    elsif params.has_key? :division_id
      ds = DivisionSeason.find(params[:division_id])
      if params.has_key? :role
        roles = ds.team_division_season_roles.select{ |tdsr| tdsr.role.to_s == params[:role] }

      # else, assume they don't wanted deleted.
      else
        roles = ds.team_division_season_roles.select{ |tdsr| tdsr.role != TeamDSRoleEnum::DELETED }
      end

      @teams = roles.map(&:team)
    # else fetch teams for a user...
    else
      user = current_user
  		
      if current_user.nil? || params[:user_id] #If you are not logged in...  TODO Is there a helper function for this standard check?
        user = User.find(params[:user_id]) #This line should throw if user_id is not set. Do we need to be more explicit?
        template = 'index_reduced_gamecard'
      end
      
      authorize! :read, user
      @teams = user.teams
    end
    
    # TODO Should rename to reduced instead of gamecard since this template is very handy such as for this index action.
    render template, formats: [:json], status: :ok
	end

	def show
		@team = Team.find(params[:id])
		authorize! :read, @team

		respond_with @team	
	end

	def create
		authorize! :create, Team.new
    user = current_user

    raise InvalidParameter.new('team data not specified') unless params.has_key? :team

    tenant = LandLord.new(params[:team][:tenant_id].to_i).tenant

    # ********* THIS IS SHIT, but pointless to do anything else before other
    #            tenants need this kind of shit too.
    settings = nil
    if tenant.id == TenantEnum::O2_TOUCH_ID
      params[:team][:sport] = SportsEnum::RUGBY
      params[:team][:colour1] = tenant.colour_1
      params[:team][:colour2] = tenant.colour_2
      # SHIT HACK ALERT - we're not receiving the flag we're meant to be getting
      # for this from FE, so we're figuring it out that if it doesn't have a div_id
      # it's meant to be touchbase. If there are new kinds of o2 touch teams this
      # will cause a bug. TS
      if !params.has_key? :division_id
        settings = { touchbase_team: true } if can? :manage, tenant
      end
    end

    # **** This isn't the best either , in a rush though. All needs refactor. TS
    if params.has_key? :division_id
      ds = DivisionSeason.find_by_id(params[:division_id])
      raise InvalidParameter.new("no such league") if ds.nil?

      # check :manage_teams, if div is closed for applications
      authorize! :manage_teams, ds unless can? :add_team, ds

      params[:team][:age_group] = ds.age_group
      params[:team][:sport] = ds.league.sport
      params[:team][:league_name] = ds.league.title
    end

    ActiveRecord::Base::transaction do 
      @team = Team.new({
        name: params[:team][:name],
        created_by_id: user.id,
        created_by_type: "User",
      })
      @team.settings = settings
      @team.create_profile!({
        age_group:   params[:team][:age_group],
        colour1:     params[:team][:colour1] || DefaultColourEnum::DEFAULT_1,
        colour2:     params[:team][:colour2] || DefaultColourEnum::DEFAULT_2,
        sport:       params[:team][:sport],
        league_name: params[:team][:league_name]
      })
      @team.tenant = tenant
      @team.configurable_set_parent(tenant)
      @team.save!

      TeamUsersService.add_organiser(@team, user, false)

      # add the team to a a division
      if params.has_key? :division_id
        TeamDSService.add_team(ds, @team) if can? :manage_teams, ds
        TeamDSService.add_pending_team(ds, @team) unless can? :manage_teams, ds
      end
    end
    
    render 'show', formats: [:json], location: api_v1_team_path(@team)
	end

  # TODO: merge with above create (probably)
  def guest_create
    authorize! :guest_create, Team.new
    raise InvalidParameter unless current_user.nil?
    
    tenant = LandLord.mitoo_tenant

    ActiveRecord::Base.transaction do
      @team = Team.new({
        name: params[:team][:name],
        created_by_type: "User"
      })

      @team.create_profile!({
        age_group: params[:team][:age_group],
        colour1:   params[:team][:colour1] || DefaultColourEnum::DEFAULT_1,
        colour2:   params[:team][:colour2] || DefaultColourEnum::DEFAULT_2,
        sport:     params[:team][:sport]
      })
      @team.tenant = tenant
      @team.configurable_set_parent(tenant)

      @team.save!
    end

    # TODO: js must grab the uuid, set as cookie, and pass in params to
    #         user_registrations#new_team_organiser as :team_uuid
    render 'show', formats: [:json], locals: { show_uuid: true }, location: api_v1_team_path(@team), status: :ok
  end

  # TODO: merge with below update (probably)
  def guest_update
    raise InvalidParameter unless current_user.nil? && params.has_key?(:team_uuid)
    @team = Team.find_by_uuid(params[:team_uuid])
    raise ActiveRecord::RecordNotFound.new("No such team") if @team.nil?
    authorize! :guest_update, @team

    ActiveRecord::Base.transaction do
      @team.name = params[:team][:name]
      @team.save!

      @team.profile.update_attributes!({
        age_group: params[:team][:age_group],
        colour1:   params[:team][:colour1] || @team.profile.colour1,
        colour2:   params[:team][:colour2] || @team.profile.colour2,
        sport:     params[:team][:sport]
      })
      @team.profile.save!
    end

    render 'show', formats: [:json], locals: { show_uuid: true }, location: api_v1_team_path(@team), status: :ok
  end

  def add_demo_users
    @team = Team.find(params[:id])
    authorize! :manage, @team
    raise InvalidParameter unless DemoService.add_demo_users(@team)
    
    render :inline => Rabl.render(@team.members, 'api/v1/users/index_reduced_squad', view_path: 'app/views', formats: [:json], :scope => BFFakeContext.new, handlers: [:rabl])
  end

  def remove_demo_users
    @team = Team.find(params[:id])
    authorize! :manage, @team
    raise InvalidParameter unless DemoService.remove_demo_users(@team)
    
    render :inline => Rabl.render(@team.members, 'api/v1/users/index_reduced_squad', view_path: 'app/views', formats: [:json], :scope => BFFakeContext.new, handlers: [:rabl])
  end

  # TODO: restful up this shit. TS
  def send_schedule
    team = Team.find(params[:id])
    authorize! :manage, team

    # used to send out the schedule.
    # now removed, as we send out weekly schedules instead/updates within 7 days

    render json: { schedule_sent: true }
  end

  def update
    @team = Team.find(params[:id])
    authorize! :manage, @team

    attrs = params[:team]

    @team.name = attrs[:name]
    @team.save!
    
    @team.profile.sport = attrs[:sport] unless attrs[:sport].nil?
    @team.profile.league_name = attrs[:league_name] unless attrs[:league_name].blank?
    @team.profile.age_group = attrs[:age_group] unless attrs[:age_group].blank?
    @team.profile.colour1 = attrs[:colour1] unless attrs[:colour1].blank?
    @team.profile.colour2 = attrs[:colour2] unless attrs[:colour2].blank?
    @team.profile.save!
    
    render :show, formats: [:json], status: :ok
  end

  def follow
    # **** there is a version of this code in facebook_reg_contr. change there too. TS #megahack
    team_id = params[:team].nil? ? params[:id] : params[:team][:id]
    @team = Team.find(team_id)
    @user = current_user

    if !@team.nil?
      authorize! :follow, @team
      
      head :ok and return if @team.followers.include? @user

      @team_role = TeamUsersService.add_follower(@team, @user, @user)
      md = { team_id: @team.id, processor: 'Ns2::Processors::TeamRolesProcessor' }
      AppEventService.create(@team_role, @user, "created", md)

      platform = get_platform

      finished(:user_followed_team)
    end

    head :ok
  end

  def send_activation_links
    team = Team.find(params[:id])
    authorize! :manage, team

    ae_meta_data = { }

    if team.is_o2_touch_team?
      ae_meta_data = { processor: 'Ns2::Processors::O2TouchProcessor' }
    end

    sent_to_organisers = []
    team.organisers.each do |o|
      next if o.has_activated_account?
      AppEventService.create(team, o, "organiser_imported", ae_meta_data)
      sent_to_organisers << o.id
    end

    sent_to_players = []
    team.players.each do |p|
      next if p.has_activated_account?
      AppEventService.create(team, p, "player_imported", ae_meta_data)
      sent_to_players << p.id
    end
    
    return_data = {
      organisers: sent_to_organisers,
      players: sent_to_players
    }

    render json: return_data
  end

	def destroy
		head :not_implemented
	end
end