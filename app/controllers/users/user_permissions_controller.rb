class Users::UserPermissionsController < ApplicationController  

  def index
    user = current_or_guest_user
    if user.nil?
      render json=> {}
      return
    end
    
    if !params[:event_id].nil?
      @event = Event.find(params[:event_id])
    
      permissions = {
        "canManageAvailability" => (can? :manage_event, @event),
        "canEditEvent" => (can? :manage_event, @event),
        
        "canViewAllDetails" => (can? :read_all_details, @event),
        
        "canPostMessage" => (can? :create_message, @event),
        "canViewMessages" => (can? :read_messages, @event),
        
        "canSendInvites" => (can? :send_invites, @event),
        
        "canUsePrivateInvite" => (can? :use_private_invite, @event),
        "canUseOpenInvite" => (can? :use_open_invite, @event),
        
        "canRespondToPrivateInvite" => (can? :respond_to_invite, @event)
      }
      
      render json: permissions
      return
    end
      
  end
end