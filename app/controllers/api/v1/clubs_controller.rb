class Api::V1::ClubsController < Api::V1::ApplicationController
	skip_before_filter :authenticate_user!, only: [:show]

	def show
		@club = Club.find(params[:id])
		authorize! :read, @club

		respond_with @club	
	end
end