class TeamService

  # Copy a team
  # Creates a new team with the same name, settings and member structure
  def self.copy(team)

    new_team = team.dup
    new_team.save

    # Profile
    nt_profile = team.profile.dup
    nt_profile.save
    new_team.profile = nt_profile

    # Team Roles
    team.team_roles.each do |tr|
      new_tr = tr.dup
      new_team.team_roles << new_tr
    end

  end

  # Archives a team
  # Renames an existing team and removes members from a team
  #
  # Options:
  # :remove_members => true - Removes all players and admins (except for creator)
  def self.archive(team, options=nil)
    
    team.name = team.name + " (Old)"
    team.save

    # Team Roles
    team.team_roles.each do |tr|
      next if tr.user_id == team.created_by_id
      tr.destroy
    end

  end
end