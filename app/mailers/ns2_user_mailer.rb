class Ns2UserMailer < ActionMailer::Base
  
  include MailerHelper
  include EmailSubjectHelper
  include IncomingMailHelper

  add_template_helper(ApplicationHelper) # TODO use helper :application? 
  helper :km, :event_update, :mailer

  default from: NOTIFICATIONS_FROM_ADDRESS
  layout 'notifier'

  def user_imported(recipient_id, tenant_id, data)
    @tenant = Tenant.find(tenant_id)
    @recipient = User.find(recipient_id)

    @team = Team.find(data[:team_id])
    @team_invite = data.has_key?(:team_invite_id) ? TeamInvite.find(data[:team_invite_id]) : nil

    from = determine_mail_from_for_general_notifications(@tenant)
    to = format_email_to_user(@recipient)
    subject = subject_for_user_imported(@team)

    @no_league_header = true

    mail(:from => from, :to => to, :subject => subject)
  end

  def user_imported_generic(recipient_id, tenant_id, data)
    @tenant = Tenant.find(tenant_id)
    @recipient = User.find(recipient_id)

    from = determine_mail_from_for_general_notifications(@tenant)
    to = format_email_to_user(@recipient)
    subject = subject_for_user_imported_generic(@recipient)

    @no_league_header = true

    mail(:from => from, :to => to, :subject => subject)
  end

  def follower_registered(recipient_id, tenant_id, data)
    @tenant = Tenant.find(tenant_id)
  	@team = Team.find(data[:team_id])
  	@recipient = User.find(recipient_id)

    @team_invite = data.has_key?(:team_invite_id) ? TeamInvite.find(data[:team_invite_id]) : nil

    from = determine_team_from_address(@team, @recipient)
    to = format_email_to_user(@recipient)
    subject = subject_for_follower_registered(@recipient, @team)

    # Include generated password
    @tmp_password = @recipient.generated_password
    @recipient.clear_generated_password # Move this to be part of the getter = "self destructing" field
  
    I18n.with_locale(@recipient.locale) do
      mail(:from => from, :to => to, :subject => subject)
    end
  end

  def follower_invited(recipient_id, tenant_id, data)
    @tenant = Tenant.find(tenant_id)
    @team = Team.find(data[:team_id])
    @recipient = User.find(recipient_id)

    @team_invite = data.has_key?(:team_invite_id) ? TeamInvite.find(data[:team_invite_id]) : nil
    @inviter = @team_invite.sent_by unless @team_invite.nil?

    @inviter_name = @inviter.nil? ? "Someone" : @inviter.first_name.titleize

    from = determine_team_from_address(@team, @recipient)
    to = format_email_to_user(@recipient)
    subject = subject_for_follower_invited(@team, @inviter)

    mail(:from => from, :to => to, :subject => subject)
  end
end