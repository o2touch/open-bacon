class Admin::UnclaimedTeamProfilesController < Admin::AdminController

  def index
    @teams = UnclaimedTeamProfile.all
    
    @claimed_teams = UnclaimedTeamProfile.where("team_id IS NOT NULL")
  end

  def faft
    @teams = FaFullTime::FaftTeam.all_with_colour
  end
    
end