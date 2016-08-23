class EventMailer < ActionMailer::Base
	include EventUpdateHelper
  include MailerHelper
  include EmailSubjectHelper
  include IncomingMailHelper
  
  add_template_helper(ApplicationHelper) # TODO use helper :application? 
  helper :km, :event_update, :mailer

  default from: NOTIFICATIONS_FROM_ADDRESS
  layout 'notifier'

  # PLAYERS
  def player_event_created(recipient_id, tenant_id, data)
    @tenant = Tenant.find(tenant_id)
    @event = Event.find(data[:event_id])
    # make sure we don't send if the event is in the passed
    # This is for the failed one of these we have... can be deleted after. TS
    return if @event.time < Time.now.utc
    @team = Team.find(data[:team_id])
    @organiser = User.find(data[:actor_id])

    @recipient = User.find(recipient_id)

    from = determine_team_from_address(@team, @recipient)
    subject = subject_for_event_created(@event)
    to = format_email_to_user(@recipient)


    mail(:from => from, :to => to, :subject => subject)
  end

  def player_event_postponed(recipient_id, tenant_id, data)
    @tenant = Tenant.find(tenant_id)
    @event = Event.find(data[:event_id])
    @team = Team.find(data[:team_id])
    @organiser = User.find(data[:actor_id])

    @recipient = User.find(recipient_id)

    from = determine_team_from_address(@team, @recipient)
    subject = subject_for_event_postponed(@event)
    to = format_email_to_user(@recipient)

    mail(:from => from, :to => to, :subject => subject)
  end

  def player_event_rescheduled(recipient_id, tenant_id, data)
    @tenant = Tenant.find(tenant_id)
    @event = Event.find(data[:event_id])
    @team = Team.find(data[:team_id])
    @organiser = User.find(data[:actor_id])

    @recipient = User.find(recipient_id)

    from = determine_team_from_address(@team, @recipient)
    subject = subject_for_event_rescheduled(@event)
    to = format_email_to_user(@recipient)

    mail(:from => from, :to => to, :subject => subject)
  end

  def player_event_cancelled(recipient_id, tenant_id, data)
    @tenant = Tenant.find(tenant_id)
    @event = Event.find(data[:event_id])
    @organiser = User.find(data[:actor_id])
    @league = League.find(data[:league_id]) if data.has_key? :league

    @user = User.find(recipient_id)

    @time_zone_mismatch = @user.time_zone != @event.time_zone

    from = determine_team_from_address(@event.team, @user)
    subject = subject_for_event_cancelled(@event)
    to = format_email_to_user(@user)
    
    mail(:from => from, :to => to, :subject => subject)
  end

  def player_event_activated(recipient_id, tenant_id, data)
    @tenant = Tenant.find(tenant_id)
    @event = Event.find(data[:event_id])
    @organiser = User.find(data[:actor_id])
    @league = League.find(data[:league_id]) if data.has_key? :league

    @user = User.find(recipient_id)

    @time_zone_mismatch = @user.time_zone != @event.time_zone

    from = determine_team_from_address(@event.team, @user)
    subject = subject_for_event_activated(@event)    
    to = format_email_to_user(@user)

    mail(:from => from, :to => to, :subject => subject)
  end
      
  def player_event_updated(recipient_id, tenant_id, data)
    @tenant = Tenant.find(tenant_id)
    @event = Event.find(data[:event_id])
    @organiser = User.find(data[:actor_id])
    @league = League.find(data[:league_id]) if data.has_key? :league

    @user = User.find(recipient_id)

    @time_zone_mismatch = @user.time_zone != @event.time_zone
    @updates = data[:updates]
    @teamsheet_entry = @event.teamsheet_entry_for_user(@user)

    from = determine_team_from_address(@event.team, @user)
    subject = subject_for_event_details_updated(@event)
    to = format_email_to_user(@user)
    
    mail(:from => from, :to => to, :subject => subject)
  end 

  # FOLLOWERS
  def follower_event_created(recipient_id, tenant_id, data)
    @tenant = Tenant.find(tenant_id)
    @event = Event.find(data[:event_id])
    # make sure we don't send if the event is in the passed
    # This is for the failed one of these we have... can be deleted after. TS
    return if @event.time < Time.now.utc
    @team = Team.find(data[:team_id])
    @organiser = User.find(data[:actor_id])

    @recipient = User.find(recipient_id)

    from = determine_team_from_address(@event.team, @recipient)
    subject = subject_for_follower_event_created(@event)
    to = format_email_to_user(@recipient)

    mail(:from => from, :to => to, :subject => subject)
  end

  def follower_event_postponed(recipient_id, tenant_id, data)
    @tenant = Tenant.find(tenant_id)
    @event = Event.find(data[:event_id])
    @team = Team.find(data[:team_id])
    @organiser = User.find(data[:actor_id])

    @recipient = User.find(recipient_id)

    from = determine_team_from_address(@event.team, @recipient)
    subject = subject_for_follower_event_postponed(@event)
    to = format_email_to_user(@recipient)

    mail(:from => from, :to => to, :subject => subject)
  end

  def follower_event_rescheduled(recipient_id, tenant_id, data)
    @tenant = Tenant.find(tenant_id)
    @event = Event.find(data[:event_id])
    @team = Team.find(data[:team_id])
    @organiser = User.find(data[:actor_id])

    @recipient = User.find(recipient_id)

    from = determine_team_from_address(@event.team, @recipient)
    subject = subject_for_follower_event_rescheduled(@event)
    to = format_email_to_user(@recipient)

    mail(:from => from, :to => to, :subject => subject)
  end

  def follower_event_cancelled(recipient_id, tenant_id, data)
    @tenant = Tenant.find(tenant_id)
    @event = Event.find(data[:event_id])
    @organiser = User.find(data[:actor_id])
    @league = League.find(data[:league_id]) if data.has_key? :league

    @user = User.find(recipient_id)

    @time_zone_mismatch = @user.time_zone != @event.time_zone

    from = determine_team_from_address(@event.team, @user)
    subject = subject_for_follower_event_cancelled(@event)
    to = format_email_to_user(@user)
    
    mail(:from => from, :to => to, :subject => subject)
  end

  def follower_event_activated(recipient_id, tenant_id, data)
    @tenant = Tenant.find(tenant_id)
    @event = Event.find(data[:event_id])
    @organiser = User.find(data[:actor_id])
    @league = League.find(data[:league_id]) if data.has_key? :league

    @user = User.find(recipient_id)

    @time_zone_mismatch = @user.time_zone != @event.time_zone

    from = determine_team_from_address(@event.team, @user)
    subject = subject_for_follower_event_activated(@event)    
    to = format_email_to_user(@user)

    mail(:from => from, :to => to, :subject => subject)
  end
      
  def follower_event_updated(recipient_id, tenant_id, data)
    @tenant = Tenant.find(tenant_id)
    @event = Event.find(data[:event_id])
    @organiser = User.find(data[:actor_id])
    @league = League.find(data[:league_id]) if data.has_key? :league

    @user = User.find(recipient_id)

    @time_zone_mismatch = @user.time_zone != @event.time_zone
    @updates = data[:updates] || []

    from = determine_team_from_address(@event.team, @user)
    subject = subject_for_follower_event_updated(@event)
    to = format_email_to_user(@user)
    
    mail(:from => from, :to => to, :subject => subject)
  end

  def player_event_invite_reminder(recipient_id, tenant_id, data)
    @tenant = Tenant.find(tenant_id)
    @event = Event.find(data[:event_id])
    @organiser = User.find(data[:actor_id])
    @league = League.find(data[:league_id]) if data.has_key? :league
    @tse = TeamsheetEntry.find(data[:tse_id])

    @user = User.find(recipient_id)
    @time_zone_mismatch = @user.time_zone != @event.time_zone

    from = determine_team_from_address(@event.team)
    subject = subject_for_invite_reminder(@event)
    to = format_email_to_user(@user)

    mail(:from => from, :to => to, :subject => subject)
  end

  def parent_event_invite_reminder(recipient_id, tenant_id, data)
    @tenant = Tenant.find(tenant_id)
    @event = Event.find(data[:event_id])
    @organiser = User.find(data[:actor_id])
    @league = League.find(data[:league_id]) if data.has_key? :league
    @tse = TeamsheetEntry.find(data[:tse_id])

    @junior = User.find(data[:junior_id])
    @parent = User.find(recipient_id)
    @time_zone_mismatch = @parent.time_zone != @event.time_zone
    
    from = determine_team_from_address(@event.team)
    subject = subject_for_invite_reminder(@event, @junior)
    to = format_email_to_user(@parent)

    mail(:from => from, :to => to, :subject => subject)
  end

  def parent_event_postponed(recipient_id, tenant_id, data)
    return nil
  end

  def parent_event_created(recipient_id, tenant_id, data)
    @tenant = Tenant.find(tenant_id)
    @junior = User.find(data[:junior_id])
    @parent = User.find(recipient_id)
    @organiser = User.find(data[:actor_id])
    @event = Event.find(data[:event_id])
    # make sure we don't send if the event is in the passed
    # This is for the failed one of these we have... can be deleted after. TS
    return if @event.time < Time.now.utc

    from = determine_team_from_address(@event.team)
    subject = subject_for_event_created(@event, @junior)
    to = format_email_to_user(@parent)
    
    mail(:from => from, :to => to, :subject => subject)
  end

  def parent_event_cancelled(recipient_id, tenant_id, data)
    @tenant = Tenant.find(tenant_id)
    @junior = User.find(data[:junior_id])
    @parent = User.find(recipient_id)
    @organiser = User.find(data[:actor_id])
    @event = Event.find(data[:event_id])

    from = determine_team_from_address(@event.team)
    subject = subject_for_event_cancelled(@event, @junior)
    to = format_email_to_user(@parent)
    
    mail(:from => from, :to => to, :subject => subject)
  end
      
  def parent_event_activated(recipient_id, tenant_id, data)
    @tenant = Tenant.find(tenant_id)
    @junior = User.find(data[:junior_id])
    @parent = User.find(recipient_id)
    @event = Event.find(data[:event_id])

    from = determine_team_from_address(@event.team)
    subject = subject_for_event_activated(@event, @junior)
    to = format_email_to_user(@parent)

    mail(:from => from, :to => to, :subject => subject)
  end

  def parent_event_updated(recipient_id, tenant_id, data)
    @tenant = Tenant.find(tenant_id)
    @junior = User.find(data[:junior_id])
    @parent = User.find(recipient_id)
    @event = Event.find(data[:event_id])
    @updates = data[:updates]

    from = determine_team_from_address(@event.team)
    subject = subject_for_event_details_updated(@event, @junior)
    to = format_email_to_user(@parent)
    
    mail(:from => from, :to => to, :subject => subject)
  end
end