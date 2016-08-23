class Admin::ClubsController < Admin::AdminController
  require 'csv'

	def index
		@clubs = Club.find(:all, order: :name)
	end

	def show
		@club = Club.find_by_slug(params[:id])
	end

	def new

	end

	def create
		#Rails.logger.debug params.to_yaml
    @club = Club.new(params[:club])
    @club.profile.sport = SportsEnum::SOCCER if @club.profile.sport.blank?
    @club.profile.age_group = 99 # don't give a shit about this, in this context...

    respond_to do |format|
      if @club.save && @club.profile.save
        format.html { redirect_to admin_clubs_path, notice: 'League was successfully created.' }
        format.json { render json: @club, status: :created, location: @league }
      else
        format.html { render action: "new" }
        format.json { render json: @club.errors, status: :unprocessable_entity }
      end
    end
	end

	def edit
		@club = Club.find_by_slug(params[:id])
	end

	def update
    @club = Club.find_by_slug(params[:id])
    @club.update_attributes(params[:club])
    @club.profile.sport = SportsEnum::SOCCER if @club.profile.sport.blank?
    @club.profile.age_group = 99 # don't give a shit about this, in this context...

    respond_to do |format|
      if @club.save && @club.profile.save
        format.html { redirect_to [:admin, @club], notice: 'League was successfully created.' }
        format.json { render json: @club, status: :created, location: @league }
      else
        format.html { render action: "new" }
        format.json { render json: @club.errors, status: :unprocessable_entity }
      end
    end
	end

	def destroy
		@club = Club.find_by_slug(params[:id])
		@club.destroy
		redirect_to admin_clubs_path
	end

  def upload
    if params[:csv].nil?
      flash[:notice] = "There was no file to import"
      redirect_to admin_clubs_path and return
    end

    line_number = 1
    CSV.foreach params[:csv].path, headers: true do |row|
      row_hash = row.to_hash

      if !Club.find_by_faft_id(row_hash['id']).nil?
        Rails.logger.info("*** skipping as dup: #{row_hash['club_name']}")
        next
      end

      if row_hash['ground_title'].nil? || row_hash['ground_address'].nil?
        Rails.logger.info("*** skipping as no location data #{row_hash['club_name']}")
        next
      end

      ClubBuilderWorker.perform_async(row_hash)
    end
    redirect_to admin_clubs_path
  end
  
end