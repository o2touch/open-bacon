class TeamRoleMailer < ActionMailer::Base

  include MailerHelper
  include EmailSubjectHelper
  include IncomingMailHelper
  
  add_template_helper(ApplicationHelper) # TODO use helper :application? 
  helper :km, :event_update, :mailer

  default from: NOTIFICATIONS_FROM_ADDRESS
  layout 'notifier'

	def follower_created(recipient_id, tenant_id, data)
    @tenant = Tenant.find(tenant_id)
		@team = Team.find(data[:team_id])
		@recipient = User.find(recipient_id)

    from = determine_team_from_address(@team, @recipient)
    to = format_email_to_user(@recipient)
    subject = subject_for_follower_created(@recipient, @team)

		mail(from: from, to: to, subject: subject)
	end

  def player_o2_touch_player_role_created(recipient_id, tenant_id, data)
    @tenant = Tenant.find(tenant_id)
    @team = Team.find(data[:team_id])
    @recipient = User.find(recipient_id)
    @event = Event.find(data[:event_id])

    from = determine_team_from_address(@team, @recipient)
    to = format_email_to_user(@recipient)
    subject = subject_for_o2_touch_player_role_created(@recipient)

    mail(from: from, to: to, subject: subject)
  end

  def organiser_o2_touch_player_role_created(recipient_id, tenant_id, data)
    @tenant = Tenant.find(tenant_id)
    @team = Team.find(data[:team_id])
    @recipient = User.find(recipient_id)
    @event = Event.find(data[:event_id])
    @player = User.find(data[:player_id])

    from = determine_team_from_address(@team, @recipient)
    to = format_email_to_user(@recipient)
    subject = subject_for_organiser_o2_touch_player_role_created(@player, @team)

    mail(from: from, to: to, subject: subject)
  end
end