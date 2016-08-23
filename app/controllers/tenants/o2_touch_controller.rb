class Tenants::O2TouchController < ApplicationController
  
  def landing_page

    if current_user.nil?
      redirect_to "http://www.englandrugbyfiles.com/o2touch/" and return
    end

    team = current_user.teams.first

    if !team.nil?
      redirect_to team_url(team) and return
    end

    redirect_to user_url(current_user)
  end

  def search
    render layout: false
  end

end