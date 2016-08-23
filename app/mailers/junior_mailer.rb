class JuniorMailer < ActionMailer::Base  
  include MailerHelper
  include EmailSubjectHelper
  include IncomingMailHelper

  helper :km, :application, :mailer

  default from: NOTIFICATIONS_FROM_ADDRESS
  
  layout 'notifier'
 
  def scheduled_event_reminder_single(parent_id, junior_id, teamsheet_entry_id)
    @parent = User.find(parent_id)
    @junior = User.find(junior_id)
    @teamsheet_entry = TeamsheetEntry.find(teamsheet_entry_id)
    @event = @teamsheet_entry.event
    @tenant = LandLord.new(@event).tenant
  
    from = determine_mail_from_for_automated_email(@tenant)
    subject = subject_for_scheduled_event_reminder_single(@event, @junior)
    to = format_email_to_user(@parent)
    
    mail(:from => from, :to => to, :subject => subject)
  end

  def scheduled_event_reminder_multiple(parent_id, junior_id, teamsheet_entry_ids, same_day)
    @parent = User.find(parent_id)
    @junior = User.find(junior_id)
    @teamsheet_entries = TeamsheetEntry.find(teamsheet_entry_ids)
    @same_day = same_day
    @tenant = LandLord.new(@teamsheet_entries.first.event).tenant

    from = determine_mail_from_for_automated_email(@tenant)
    subject = subject_for_scheduled_event_reminder_multiple(@teamsheet_entries, same_day, @junior)
    to = format_email_to_user(@parent)

    mail(:from => from, :to => to, :subject => subject)
  end

  def event_upcoming_reminder(parent_id, junior_id, event_id, organiser_id, teamsheet_entry_id)
    teamsheet_entry = TeamsheetEntry.find(teamsheet_entry_id)
    return unless teamsheet_entry.user.should_send_email?

    @junior = User.find(junior_id)
    @parent = User.find(parent_id)
    @organiser = User.find(organiser_id)
    @event = Event.find(event_id)
    @tenant = LandLord.new(@event).tenant
    
    from = determine_mail_from_for_event(@event, @organiser)
    subject = subject_for_event_reminder(@event)
    to = format_email_to_user(@parent)

    mail(:from => from, :to => to, :subject => subject)
  end

  def parent_invited_to_team(parent_id, team_id, junior_ids, organiser_id, team_invite_token)
    @team_invite_token = team_invite_token
    @parent = User.find(parent_id)
    @team = Team.find(team_id)
    @juniors = User.find(junior_ids)
    @organiser = User.find(organiser_id)
    @tenant = LandLord.new(@team).tenant

    from = determine_mail_from_for_team(@team, @organiser)
    subject = subject_for_new_user_invited_to_team(@team, @parent)
    to = format_email_to_user(@parent)

    mail(:from => from, :to => to, :subject => subject)
  end

  # Although copied to the team mailer, the app still uses this one, rather than
  #   the AppEvent/TeamMailer one, so left un-commented. TS
  def event_schedule(parent_id, team_id, junior_ids, organiser_id, event_ids, team_invite_token)
    @organiser = User.find(organiser_id)
    @parent = User.find(parent_id)
    @juniors = User.find(junior_ids)
    @team = Team.find(team_id)
    @tenant = LandLord.new(@team).tenant
    
    # order events as per ids
    @events = Event.find(event_ids, :order => "field(id, #{event_ids.join(',')})")
    @team_invite_token = team_invite_token

    from = determine_mail_from_for_team(@team, @organiser)
    subject = subject_for_event_schedule(@team)
    to = format_email_to_user(@parent)
    
    mail(:from => from, :to => to, :subject => subject)
  end
end
