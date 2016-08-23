class Api::V1::DivisionSeasonsController < Api::V1::ApplicationController
	skip_before_filter :authenticate_user!, only: [:standings, :show, :index]
	skip_authorization_check only: [:index]

	def index
		league = League.find(params[:api_v1_league_id])

		@divisions = league.divisions # only returns current DS

		respond_with @divisions
	end

	def show
		@division = DivisionSeason.find(params[:id])
		authorize! :read, @division

		@show_edits = false
		if params.has_key? :edits
			authorize! :read_unpublished, @division
			@show_edits = true
			@division.fixtures.each do |f|
				f.show_edits!
			end
		end

		respond_with @division
	end

	def publish_edits
		@division = DivisionSeason.find(params[:id])
		authorize! :update, @division
		raise InvalidParameter.new("Already publishing edits for this division") if @division.edit_mode > 1

		# TODO: Change this back to raising an exception when FE has implemented disabling publish/discard buttons when no edits
		#raise InvalidParameter.new("There are no edits for this division") if @division.edit_mode < 1
		head :created and return if @division.edit_mode < 1

		@division.update_attributes!({edit_mode: 2})

		# nb. App events created by below methods, as publish must happen first.
		DivisionSeason.delay.publish_edits!(@division.id, current_user.id) if @division.launched?
		DivisionSeason.delay.launch!(@division.id, current_user.id) unless @division.launched?


		head :created
	end

	def clear_edits
		@division = DivisionSeason.find(params[:id])
		authorize! :update, @division

		@division.fixtures.each do |f|
			f.clear_edits!
		end
		@division.update_attributes!({edit_mode: 0})

		head :ok
	end

	# I don't see any point in storing this in a model, as
	# we can calculate it easily, and then aggressively cache it.
	# If shit gets slow, let's automatically calculate this on
	# change results or points and stick it in redis
	def standings
		@division = DivisionSeason.find(params[:id])
		authorize! :read, @division

		raise InvalidParameter.new("show standings disabled for division") unless @division.show_standings?

		division_presenter = DivisionPresenter.new(@division)
		respond_with division_presenter.standings
	end

	def open_registrations
		@ds = DivisionSeason.find(params[:id])
		authorize! :update, @ds

		@ds.config.applications_open = true
		@ds.save

		head :ok
	end

	def close_registrations
		@ds = DivisionSeason.find(params[:id])
		authorize! :update, @ds

		@ds.config.applications_open = false
		@ds.save

		head :ok
	end
end