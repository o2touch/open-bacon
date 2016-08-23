class TeamInvitesController < ApplicationController
  layout "application"

include TeamUrlHelper

  # If a user follows a team invite link, log them in and send them to the team
  def show
    team_invite = TeamInvite.find_by_token(params[:token])

    if team_invite.nil? || team_invite.sent_to.nil? || team_invite.team.nil? || team_invite.sent_to.role?(RoleEnum::NO_LOGIN) || team_invite.sent_to.role?(RoleEnum::JUNIOR) 
      redirect_to root_path and return
    end

    #SR - Removed token expire clause

    #Login and goto team page if REGISTERED or INVITED

    team = team_invite.team
    sign_in team_invite.sent_to
    
    redirect_to default_team_path(team_invite.team)
  end
end
