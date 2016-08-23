class Api::V1::TeamsheetEntriesController < Api::V1::ApplicationController

  def index
    #totallyshit 
    event = Event.find(params[:id]) if params.has_key? :id
    event = Event.find(params[:event_id]) if params.has_key? :event_id

    authorize! :read_all_details, event

    @teamsheet_entries = event.cached_teamsheet_entries

    if params.has_key? :user_id
      @teamsheet_entries.reject!{ |tse| tse.user_id != params[:user_id].to_i }

      # so that we render it without an array
      @teamsheet_entry = @teamsheet_entries.first
      render 'show', formats: [:json], handlers: [:rabl]
    else
      respond_with @teamsheet_entries
    end
  end

  #SR - There is no obvious way to provide minimized information for the mobile.
  #In the mobile we dont care about role etc at the moment hence this endpoint was created.
  def mindex
    event = Event.find(params[:id])
    authorize! :read_all_details, event
    @teamsheet_entries = event.cached_teamsheet_entries

    respond_to do |format| 
      format.html { render }
      format.json { render(template: "api/v1/teamsheet_entries/mindex", formats: [:json], handlers: [:rabl])}
    end    
  end

end
