class TeamMailer < ActionMailer::Base
  
  include EventUpdateHelper
  include MailerHelper
  include EmailSubjectHelper
  include IncomingMailHelper
  
  add_template_helper(ApplicationHelper) # TODO use helper :application? 
  helper :km, :event_update, :mailer

  default from: NOTIFICATIONS_FROM_ADDRESS
  layout 'notifier'

  # SCHEDULE CREATED EMAIL
  # Sent when:
  #   - A new player/parent/follower is added to an existing team
  #   - Leagues: user recevies this when division is launched

  # Generic Schedule Created Template
  def member_schedule_created(recipient_id, tenant_id, data, render_parent=false)
    @tenant = Tenant.find(tenant_id)
    valid_data, @recipient, @team, @league, @events, @team_invite_token = process_schedule_data(recipient_id, data)
    return if !valid_data

    if render_parent
      valid_parent_data, @juniors = process_parent_data(data)
      return if !valid_parent_data
    end

    from, to = get_mail_from_to_data(@team, @recipient)
    subject = subject_for_event_schedule(@team)
    mail(:from => from, :to => to, :subject => subject, :template_name => 'member_schedule_created')
  end

  def player_schedule_created(recipient_id, tenant_id, data)
    member_schedule_created(recipient_id, tenant_id, data)
  end

  def follower_schedule_created(recipient_id, tenant_id, data)
    member_schedule_created(recipient_id, tenant_id, data)
  end

  def parent_schedule_created(recipient_id, tenant_id, data)
    member_schedule_created(recipient_id, tenant_id, data, true)
  end


  # SCHEDULE UPDATED EMAIL
  # Sent to players/parents/followers of all teams when schedule update is triggered

  # Generic Schedule Updated Template
  def member_schedule_updated(recipient_id, tenant_id, data, render_parent=false)
    @tenant = Tenant.find(tenant_id)
    valid_data, @recipient, @team, @league, @events, @team_invite_token = process_schedule_data(recipient_id, data)
    return if !valid_data

    @juniors = nil
    if render_parent
      valid_parent_data, @juniors = process_parent_data(data)
      return if !valid_parent_data
    end

    from, to = get_mail_from_to_data(@team, @recipient)
    subject = subject_for_event_schedule_update(@team, @juniors)
    mail(:from => from, :to => to, :subject => subject, :template_name => 'member_schedule_updated')
  end

  def player_schedule_updated(recipient_id, tenant_id, data)
    member_schedule_updated(recipient_id, tenant_id, data)
  end

  def follower_schedule_updated(recipient_id, tenant_id, data)
    member_schedule_updated(recipient_id, tenant_id, data)
  end

  def parent_schedule_updated(recipient_id, tenant_id, data)
    member_schedule_updated(recipient_id, tenant_id, data, true)
  end


  # HELPERS
  # Helper to validate and process data
  def process_schedule_data(recipient_id, data)
    recipient = User.find(recipient_id)

    team = Team.find(data[:team_id])
    league = League.find(data[:league_id]) if data.has_key? :league_id
    events = Event.find(data[:event_ids], :order => "field(id, #{data[:event_ids].join(',')})") if data.has_key? :event_ids
    team_invite_token = TeamInvite.find(data[:team_invite_id]).token if data.has_key? :team_invite_id

    # Need events to be a proper email
    return false if events.nil? || events.empty?

    return [true, recipient, team, league, events, team_invite_token]
  end

  def process_parent_data(data)

    if data.has_key?(:junior_id) && !data.has_key?(:junior_ids)
      data[:junior_ids] = [data[:junior_id]]
    end

    juniors = User.find(data[:junior_ids])
    return false if juniors.nil? || juniors.empty?

    return true, juniors
  end

  def get_mail_from_to_data(team, recipient)
    from = determine_team_from_address(team, recipient)
    to = format_email_to_user(recipient)

    return from, to
  end
end