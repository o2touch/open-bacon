class TeamOrganiserMailer < ActionMailer::Base

  default from: "info@mitoo.co"

  add_template_helper(ApplicationHelper) # TODO use helper :application? 
  helper :km, :mailer

  layout 'notifier'

  #should this be accepting IDs
  def aggregated_team_roles(team_id, organiser_id, removed_organisers, removed_players, created_organisers, invited_players)
    @organiser = User.find(organiser_id)
    @team = Team.find(team_id)
    @tenant = LandLord.new(@team).tenant

    @removed_organisers = removed_organisers
    @removed_players = removed_players
    @created_organisers = created_organisers
    @invited_players = invited_players

    from = "Mitoo" + "<info@mitoo.co>"
    to = "<#{@organiser.email}>"
    subject = "Team member changes - #{@team.name}"
    
    mail(:from => from, :to => to, :subject => subject)
  end
end
