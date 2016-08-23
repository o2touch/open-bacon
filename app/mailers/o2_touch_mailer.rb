###########
# 
# This mailer is meant to be for one off emails (eg. importing), and not for general use.
# TS
#
####
class O2TouchMailer < ActionMailer::Base
	include MailerHelper
	include TeamUrlHelper

  add_template_helper(ApplicationHelper) # TODO use helper :application? 
  helper :km, :event_update, :mailer

	default from: NOTIFICATIONS_FROM_ADDRESS
	layout 'notifier'

	def organiser_imported(recipient_id, tenant_id, data)
		@tenant = Tenant.find(tenant_id)
		@recipient = User.find(recipient_id)
		@team = Team.find(data[:team_id])

		t_path = default_team_path(@team)
		@token = PowerToken.generate_token(t_path, @recipient)
		
		@hide_button_footer = true

		to = format_email_to_user(@recipient)
		from = "O2Touch via Mitoo <#{DO_NOT_REPLY_FROM_ADDRESS}>"
		subject = "Welcome to the new O2 Touch"

		mail(to: to, from: from, subject: subject)
	end

	def player_imported(recipient_id, tenant_id, data)
		@tenant = Tenant.find(tenant_id)
		@recipient = User.find(recipient_id)
		@team = Team.find(data[:team_id])

		@hide_button_footer = true

		t_path = default_team_path(@team)
		@token = PowerToken.generate_token(t_path, @recipient)

		to = format_email_to_user(@recipient)
		from = "O2Touch via Mitoo <#{DO_NOT_REPLY_FROM_ADDRESS}>"
		subject = "Welcome to the new O2 Touch"

		mail(to: to, from: from, subject: subject)
	end
end