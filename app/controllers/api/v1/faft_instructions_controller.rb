class Api::V1::FaftInstructionsController < Api::V1::ApplicationController
	skip_authorization_check only: [:index]

  # Left in as I think needed for some mobile app requests - TS 4/16
  # used to be used to figure out if faft instructions were waiting to be processed
  #  this situation can now never arrive, though, as we process shit differently. TS
	def index
    render status: :ok, json: { status: 'done' }.to_json
	end

end