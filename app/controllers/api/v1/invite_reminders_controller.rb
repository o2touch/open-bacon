class Api::V1::InviteRemindersController < Api::V1::ApplicationController  
  
  def create
    event = Event.find(params[:invite_reminder][:event_id])

    authorize! :send_invites, event

    AppEventService.create(event, current_user, :invite_reminder, {})

    render status: :ok, json: {}
  end

   def show
    @invite_reminder = InviteReminder.find(params[:id]) 

    authorize! :read, @event_reminder.teamsheet_entry.event
  end
  
end 