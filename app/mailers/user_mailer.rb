class UserMailer < ActionMailer::Base
  
  include EventUpdateHelper
  include MailerHelper
  include EmailSubjectHelper
  include IncomingMailHelper
  
  add_template_helper(ApplicationHelper) # TODO use helper :application? 
  helper :km, :event_update, :mailer

  default from: NOTIFICATIONS_FROM_ADDRESS
  layout 'notifier'

  # called from team invite processor
  def event_schedule(organiser, team, invitee, events)
    @organiser = organiser
    @team = team
    @invitee = invitee
    @events = events
    @tenant = LandLord.new(@team).tenant

    send_from = nil
    send_from = @organiser if @league.nil? # Needs Refactoring - this is a hack to ensure backward compatibility now - PR

    from = determine_mail_from_for_team(@team, send_from)
    subject = subject_for_event_schedule(@team)
    to = format_email_to_user(@invitee)

    mail(:from => from, :to => to, :subject => subject)
  end


  
  def scheduled_event_reminder_single(teamsheet_entry)

    @user = teamsheet_entry.user
    @event = teamsheet_entry.event 
    @organiser = @event.organiser
    @teamsheet_entry = teamsheet_entry
    @time_zone_mismatch = @user.time_zone != @event.time_zone
    @tenant = LandLord.new(@event).tenant

    is_tommorow = ((@event.time-Time.now) < 1.day.to_i)
    @day_of_week = is_tommorow ? "tomorrow" : "on " + @event.time.in_time_zone(@event.time_zone).strftime('%A')

    from = determine_mail_from_for_automated_email(@tenant)
    subject = subject_for_scheduled_event_reminder_single(@event)
    
    mail(:from => from, :to => "#{@user.name} <#{@user.email}>", :subject => subject)
  end

  def scheduled_event_reminder_multiple(user, teamsheet_entries)

    @user = user
    @teamsheet_entries = teamsheet_entries
    event = teamsheet_entries[0].event
    @tenant = LandLord.new(event).tenant

    all_same_day = true
    date = event.time_local.strftime("%m/%d/%Y")
    teamsheet_entries.each do |tse|
      all_same_day = false if tse.event.time_local.strftime("%m/%d/%Y") != date
    end

    from = determine_mail_from_for_automated_email(@tenant)

    # Set League if all events are part of the same league
    all_same_league = true
    league = event.team.primary_league
    teamsheet_entries.each do |tse|
      all_same_league = false if tse.event.team.primary_league != league
    end
    @league = league if all_same_league && !league.nil?

    subject = subject_for_scheduled_event_reminder_multiple(@teamsheet_entries, all_same_day)
    to = format_email_to_user(@user)

    mail(:from => from, :to => to, :subject => subject)
  end

  def parent_scheduled_event_reminder_multiple(parent, teamsheet_entries)

    @junior = teamsheet_entries[0].user
    @parent = parent
    @teamsheet_entries = teamsheet_entries
    event = teamsheet_entries[0].event
    @tenant = LandLord.new(event).tenant

    all_same_day = true
    old_date = event.time_local.strftime("%m/%d/%Y")
    teamsheet_entries.each do |tse|
      all_same_day = false if tse.event.time_local.strftime("%m/%d/%Y") != old_date
    end

    from = determine_mail_from_for_automated_email(@tenant)
    subject = subject_for_scheduled_event_reminder_multiple(@teamsheet_entries, all_same_day, @junior)
    to = format_email_to_user(@parent)

    mail(:from => from, :to => to, :subject => subject)
  end
        
  
  def new_user_invited_to_team(user_id, team_id, organiser_id, team_invite_token)
    @team_invite_token = team_invite_token
    @user = User.find(user_id)
    @team = Team.find(team_id)
    @organiser = User.find(organiser_id)
    @tenant = LandLord.new(@team).tenant

    from = determine_mail_from_for_team(@team, @organiser)
    subject = subject_for_new_user_invited_to_team(@team)
    to = format_email_to_user(@user)
    
    mail(:from => from, :to => to, :subject => subject)
  end

  # TODO: Move logic out of this method into notification system
  # def new_junior_user_invited_to_team(team_invite)
  #   @team_invite = team_invite
  #   @parent = @team_invite.sent_to
  #   @team = @team_invite.team
  #   @tenant = LandLord.new(@team).tenant

  #   # Work out which junior is in the team
  #   @children = @team.get_players_in_team(@parent.children.to_a)

  #   return nil if @children.size == 0

  #   @junior = @children[0] # Let's just get the first one for now

  #   @organiser = team_invite.sent_by

  #   from = determine_mail_from_for_team(@team, @organiser)
  #   subject = subject_for_new_user_invited_to_team(@team, @junior)
  #   to = format_email_to_user(@parent)

  #   mail(:from => from, :to => to, :subject => subject)
  # end

  # Send a confirmation email (when invited user is registered)
  def user_registered_confirmation(player)
    @user = player
    @tenant = LandLord.new(@user).tenant
    
    from = determine_mail_from_for_general_notifications(@tenant)
    to = format_email_to_user(@user)
    subject = subject_for_user_registered_confirmation
    
    mail(:from => from, :to => to, :subject => subject)
  end
  
  def bluefields_invite(bluefields_invite)
    @bluefields_invite = bluefields_invite
    @invited_by = bluefields_invite.sent_by
    @organiser = @invited_by 
    @sent_to_email = bluefields_invite.sent_to_email
    
    from = @invited_by.name + "<" + @invited_by.email + ">"
    subject = subject_for_bluefields_invite
    
    mail(:from => from, :to => "<#{@sent_to_email}>", :subject => subject)
  end
  
  
  def team_organiser_notification__new_user_invited_to_team(organiser, user, team)
    @organiser = organiser
    @user = user
    @team = team
    @tenant = LandLord.new(@team).tenant

    from = determine_mail_from_for_general_notifications(@tenant)
    to = format_email_to_user(@organiser)
    subject = "#{user.name} was invited to the team - #{team.name}"
    
    mail(:from => from, :to => to, :subject => subject)
  end

  def team_organiser_notification__user_removed_from_team(organiser, user, team)
    @organiser = organiser
    @user = user
    @team = team
    @tenant = LandLord.new(@team).tenant

    from = determine_mail_from_for_general_notifications(@tenant)
    to = format_email_to_user(@organiser)
    subject = "#{user.name} was removed from the team - #{team.name}"
    
    mail(:from => from, :to => to, :subject => subject)
  end

  def team_organiser_notification__organiser_role_revoked_from_user(organiser, user, team)
    @organiser = organiser
    @user = user
    @team = team
    @tenant = LandLord.new(@team).tenant

    from = determine_mail_from_for_general_notifications(@tenant)
    to = format_email_to_user(@organiser)
    subject = "#{user.name} has had their organizer role revoked for team - #{team.name}"
    
    mail(:from => from, :to => to, :subject => subject)
  end

  def team_organiser_notification__organiser_role_granted_to_user(organiser, user, team)
    @organiser = organiser
    @user = user
    @team = team
    @tenant = LandLord.new(@team).tenant

    from = determine_mail_from_for_general_notifications(@tenant)
    to = format_email_to_user(@organiser)
    subject = "#{user.name} was invited to be an organizer of team - #{team.name}"
    
    mail(:from => from, :to => to, :subject => subject)
  end

  # TODO: Move the logic out of here - PR
  def user_removed_from_team(user, team)
    return if user.email.nil? # Don't send email if junior user (no email) or there's no email address

    @user = user
    @team = team
    @tenant = LandLord.new(@team).tenant

    from = determine_mail_from_for_general_notifications(@tenant)
    to = format_email_to_user(@user)
    subject = "You have been removed from the team - #{team.name}"
    
    mail(:from => from, :to => to, :subject => subject)
  end

  def organiser_role_revoked_from_user(user, team)
    @user = user
    @team = team
    @tenant = LandLord.new(@team).tenant

    from = determine_mail_from_for_general_notifications(@tenant)
    to = format_email_to_user(@user)
    subject = "You have had your organizer role removed from the team - #{team.name}"
    
    mail(:from => from, :to => to, :subject => subject)
  end

  def organiser_role_granted_to_user(user, team)
    @user = user
    @team = team
    @tenant = LandLord.new(@team).tenant

    from = determine_mail_from_for_general_notifications(@tenant)
    to = format_email_to_user(@user)
    subject = "You have been added as an organizer to the team - #{team.name}"
    
    mail(:from => from, :to => to, :subject => subject)
  end

  def comment_from_email_failure(address, in_reply_to)
    from = determine_mail_from_for_automated_email(LandLord.default_tenant)
    subject = "We could not post your comment"

    headers['In-Reply-To'] = in_reply_to
    # nb. here we do not use the to address helper, as all we know
    #  about the recipient is the email address
    mail(from: from, to: address, subject: subject)
  end
end
