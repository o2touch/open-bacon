class EventMessageMailer < ActionMailer::Base  
  include MailerHelper
  include EmailSubjectHelper
  include IncomingMailHelper

  helper :km, :application, :mailer

  default from: NOTIFICATIONS_FROM_ADDRESS
  
  layout 'notifier'

  # team messages
  def player_team_message_created(recipient_id, tenant_id, data)
    @user = User.find(recipient_id)
    @tenant = Tenant.find(tenant_id)

    @message = EventMessage.find(data[:event_message_id])
    @poster = User.find(data[:actor_id])
    @team = Team.find(data[:team_id])
    @token = PowerToken.generate_token(team_path(@team), @user) unless @user.is_registered?

    to = format_email_to_user(@user)
    from =  determine_mail_from_for_user_email(@poster)
    subject = subject_for_message_posted(@message)

    headers['Reply-To'] = encode_reply_to(@user, @message.activity_item)
    headers['Message-Id'] = encode_message_id(@user, @message)
    oof_header
    mail(:from => from, :to => to, :subject => subject)
  end
  alias_method :organiser_team_message_created, :player_team_message_created
  alias_method :parent_team_message_created, :player_team_message_created

  # division messages
  def parent_division_message_created(recipient_id, tenant_id, data)
    @tenant = Tenant.find(tenant_id)
    @parent = User.find(recipient_id)

    @message = EventMessage.find(data[:event_message_id])
    @poster = User.find(data[:actor_id])
    @team = Team.find(data[:team_id])
    @division = DivisionSeason.find(data[:division_season_id])
    @league = @division.league
    
    to = format_email_to_user(@parent)
    from =  @poster.name + "<" + NOTIFICATIONS_FROM_ADDRESS + ">"# TODO: From Format Helper
    subject = "Message from #{@league.title}"# TODO: Subject Helper
  
    mail(:from => from, :to => to, :subject => subject)
  end

  def player_division_message_created(recipient_id, tenant_id, data)
    @user = User.find(recipient_id)
    @tenant = Tenant.find(tenant_id)

    @message = EventMessage.find(data[:event_message_id])
    @poster = User.find(data[:actor_id])
    @team = Team.find(data[:team_id])
    @division = DivisionSeason.find(data[:division_season_id])
    @league = @division.league
    
    to = format_email_to_user(@user)
    from =  @poster.name + "<" + NOTIFICATIONS_FROM_ADDRESS + ">"# TODO: From Format Helper
    subject = "Message from #{@league.title}"# TODO: Subject Helper
  
    mail(:from => from, :to => to, :subject => subject)
  end
  alias_method :organiser_division_message_created, :player_division_message_created

  # event messages
  def player_event_message_created(recipient_id, tenant_id, data)
    @tenant = Tenant.find(tenant_id)
    @user = User.find(recipient_id)
    @message = EventMessage.find(data[:event_message_id])
    @event = Event.find(data[:event_id])
    @token = PowerToken.generate_token(event_path(@event), @user) unless @user.is_registered?
    
    from = determine_mail_from_for_user_email(@message.user)
    subject = subject_for_message_posted(@message)
    to = format_email_to_user(@user)

    headers['Reply-To'] = encode_reply_to(@user, @message.activity_item)
    headers['Message-Id'] = encode_message_id(@user, @message)
    oof_header
    mail(:from => from, :to => to, :subject => subject)
  end
  alias_method :parent_event_message_created, :player_event_message_created
  alias_method :organiser_event_message_created, :player_event_message_created

end