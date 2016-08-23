class DivisionSeasonMailer < ActionMailer::Base
	
  include MailerHelper
  include EmailSubjectHelper

  add_template_helper(ApplicationHelper) # TODO use helper :application? 
  helper :km, :mailer

  default from: NOTIFICATIONS_FROM_ADDRESS
  layout 'notifier'

  def player_division_launched(recipient_id, tenant_id, data)
    @tenant = Tenant.find(tenant_id)
    @team_invite = TeamInvite.find(data[:team_invite_id])
    @team = Team.find(data[:team_id])
    @league = League.find(data[:league_id])
    
    @user = User.find(recipient_id)

    from = format_email_from_league(@league)
    to = format_email_to_user(@user)
    subject = "Welcome to #{@league.title}"

    #What about existing users?
    
    mail(:from => from, :to => to, :subject => subject)
  end

  def organiser_division_launched(recipient_id, tenant_id, data)
    @tenant = Tenant.find(tenant_id)
    @team_invite = TeamInvite.find(data[:team_invite_id])
    @team = Team.find(data[:team_id])
    @league = League.find(data[:league_id])

    @team_invite_token = @team_invite.token

    @user = User.find(recipient_id)

    from = format_email_from_league(@league)
    to = format_email_to_user(@user)
    subject = subject_for_organiser_division_launched(@league, @team)
    
    mail(:from => from, :to => to, :subject => subject)
  end
end