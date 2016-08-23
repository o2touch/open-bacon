class Admin::LeaguesController < Admin::AdminController
  # GET /admin/leagues
  # GET /admin/leagues.json
  def index

    filter_options = %w[faft other]

    @leagues = League.all if params[:filter].nil? || !filter_options.include?(params[:filter])
    @leagues = League.where("source_id IS NOT NULL AND source = \"faft\"") if params[:filter] == "faft"
    @leagues = League.where("source_id IS NULL") if params[:filter] == "other"

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @leagues }
    end
  end

  def clear_all_page_caches
    Division.find_each do |d|
      d.touch
    end
    redirect_to action: :index
  end

  # GET /admin/leagues/1
  # GET /admin/leagues/1.json
  def show
    # @league = League.find(params[:id]) if params[:id]
    @league = League.find_by_slug(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @league }
    end
  end

  # GET /admin/leagues/new
  # GET /admin/leagues/new.json
  def new
    @league = League.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @league }
    end
  end

  # GET /admin/leagues/1/edit
  def edit
    # @league = League.find(params[:id])
    @league = League.find_by_slug(params[:id])
  end

  # this is a shit name, as actually you can only add one
  # but I already used that method name. TS
  def add_organiser_form
  	# @league = League.find(params[:league_id])
    @league = League.find_by_slug(params[:league_id])
  end

  def add_organiser
  	@league = League.find(params[:league_id])

  	# if they gave us a user id
  	if !params[:user_id].blank?
  		u = User.find_by_id(params[:user_id])
  		if u.nil?
				flash[:notice] = "no user with id #{params[:user_id]}" 
				redirect_to admin_league_add_organiser_form_path(@league) and return
			end

			@league.add_organiser u
			flash[:notice] = "User #{u.id} (#{u.name}) added as organiser"
			redirect_to admin_leagues_path
		else
			u = User.new({
				name: params[:name],
				email: params[:email],
				mobile_number: params[:mobile_number],
				time_zone: params[:time_zone],
				country: params[:country],
				invited_by_source_user_id: current_user.id,
				invited_by_source: "LEAGUE_ADMIN"
			})
      u.add_role("Registered")

			if u.save
				@league.add_organiser u
				flash[:notice] = "New user (#{u.id}, #{u.name}) create, and added as league organiser"
				redirect_to admin_leagues_path
			else
				flash[:notice] = "Error adding user: #{u.errors.full_messages.join(", ")}"
				redirect_to admin_league_add_organiser_form_path(@league)
			end
		end
  end

  # POST /admin/leagues
  # POST /admin/leagues.json
  def create
    @league = League.new(params[:league])

    respond_to do |format|
      if @league.save
        format.html { redirect_to [:admin, @league], notice: 'League was successfully created.' }
        format.json { render json: @league, status: :created, location: @league }
      else
        format.html { render action: "new" }
        format.json { render json: @league.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /admin/leagues/1
  # PUT /admin/leagues/1.json
  def update
    # @league = League.find(params[:id])
    @league = League.find_by_slug(params[:id])

    # League Config
    # LeagueConfigKeyEnum.each do |enum|
    #   params[:league_config][LeagueConfigKeyEnum.const_get(enum)] = false unless !params[:league_config][LeagueConfigKeyEnum.const_get(enum)].nil?
    # end

    # @league.league_config = params[:league_config]


    respond_to do |format|
      if @league.update_attributes(params[:league])
        format.html { redirect_to [:admin, @league], notice: 'League was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @league.errors, status: :unprocessable_entity }
      end
    end
  end

  # This is now done by the league admin
  # def send_notifications
  #   @league = League.find(params[:league_id])

  #   EmailNotificationService.exit_league_edit_mode(@league)

  #   respond_to do |format|
  #     format.html { redirect_to [:admin, @league], notice: 'League was successfully notified.' }
  #     format.json { render json: @league, status: :created, location: @league }
  #   end
  # end

=begin
  # DELETE /admin/leagues/1
  # DELETE /admin/leagues/1.json
  def destroy
    @league = League.find(params[:id])
    @league.destroy

    respond_to do |format|
      format.html { redirect_to leagues_url }
      format.json { head :no_content }
    end
  end
=end
end
