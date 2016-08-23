class Api::V1::InviteResponsesController < Api::V1::ApplicationController
	def create
		if params.has_key? :tse_id
			tse = TeamsheetEntry.find(params[:tse_id])
		else
			tses = TeamsheetEntry.where(event_id: params[:event_id], user_id: params[:user_id])
			raise ActiveRecord::RecordNotFound.new if tses.size == 0
			tse = tses.first
		end
		authorize! :respond, tse

		invite_response = TeamsheetEntriesService.set_availability(tse, params[:response_status], current_user)
		tse.send_push_notification("update") unless invite_response.nil?

		# backbone needs a body. boooo.
		render status: :created, json: {}
	end
end
