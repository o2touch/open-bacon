module TeamUrlHelper

  def default_team_url(team, options={})
    root_url + default_team_path(team, options)
  end
  
  def default_team_path(team, options={})
    # raise ArgumentError, "No such user #{user.inspect}" unless username

    division = options[:division].nil? ? team.divisions.first : options[:division]

    if team.divisions.empty? || division.league.nil?
      team_path options.merge(:id => team.id)
    else
      league_team_path options.merge(:league_slug => division.league.slug, :division_slug => division.slug, :team_slug => team.slug)
    end
  end

end