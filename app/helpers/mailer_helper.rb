module MailerHelper

  def determine_mail_from_for_automated_email(tenant, email=nil)
    email = DO_NOT_REPLY_FROM_ADDRESS if email.nil?

    via_mitoo = ""
    via_mitoo = "via Mitoo " unless tenant.default_tenant?

    "#{I18n.t("general.app_name", locale: tenant.i18n)} #{via_mitoo}<#{email}>"
  end

  def determine_mail_from_for_user_email(user)
    "#{user.name.titleize} <#{NOTIFICATIONS_FROM_ADDRESS}>"
  end

  def determine_mail_from_for_team(team, from_user=nil)
    # Setting from_user will override all
    return determine_mail_from_for_user_email(from_user) if !from_user.nil? 

    # Is team in a league?
    return format_email_from_league(team.primary_league) if team.league?

    # Default to team founder
    determine_mail_from_for_user_email(team.founder)
  end

  # New helper to replace 'determine_mail_from_for_team'
  # This method takes into account a recipient role in the team
  def determine_team_from_address(team, recipient=nil)
    "#{team.name} <#{NOTIFICATIONS_FROM_ADDRESS}>"
  end

  # Convenience method when no team object
  def determine_mail_from_for_event(event, from_user=nil)
    determine_mail_from_for_team(event.team, from_user)
  end

  def determine_mail_from_for_general_notifications(tenant)
    via_mitoo = ""
    via_mitoo = "via Mitoo " unless tenant.default_tenant?

    "#{I18n.t("general.app_name", locale: tenant.i18n)} #{via_mitoo}<#{NOTIFICATIONS_FROM_ADDRESS}>"
  end

  def format_email_from_user(user)
    format_user_email(user)
  end

  def format_email_from_league(league)
    league.title + " via Mitoo <#{DO_NOT_REPLY_FROM_ADDRESS}>"
  end

  # Mailer to helpers

  def format_email_to_user(user)
    format_user_email(user)
  end

  def format_user_email(user)
    "#{user.name.titleize} <#{user.email}>"
  end

  # suppress out of office from MS Exchange
  def oof_header
    headers['X-Auto-Response-Suppress'] = "OOF, AutoReply"
  end

  def paperclip_url(path)
    paperclip_host = nil # Paperclip::Attachment.default_options[:fog_host]
    return path if paperclip_host.nil?
    return Paperclip::Attachment.default_options[:fog_host] + path
  end
end