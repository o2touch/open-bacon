class Hooks::SendgridController < ApplicationController
  
  respond_to :json
  
  def events
  
    params[:_json].each do |e|
      EmailEventService::process_event(e)
    end

    render status: :ok, json: { message: "Success" }
  end

end