class Api::V1::FaFullTimeController < Api::V1::ApplicationController
	skip_before_filter :authenticate_user!, only: [:division]
	skip_authorization_check only: [:division]

	def division
		json = FaFullTime::Scrapers::TeamScraper.scrape(params[:id].to_i, params[:div_id].to_i)
		render json: json
	end
end