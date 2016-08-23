class Api::V1::LocationsController < Api::V1::ApplicationController

	def index
		valid_resources = ["team", "league"]

		if valid_resources.exclude?(params[:resource])
			raise InvalidParameter.new("invalid resource type: #{params[:resource]}")
		end

		resource = params[:resource].classify.constantize
		authorize! :read, resource

		@locations = resource.find(params[:resource_id]).locations

		respond_with @locations
	end
end