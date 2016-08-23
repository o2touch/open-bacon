module DivisionUrlHelper

  def default_division_url(division, options={})
    root_url + default_division_path(division, options)
  end
  
  def default_division_path(division, options={})
  	return division_normal_path options.merge(:id => division.id) if division.league.nil?
	return division_path options.merge(league_slug: division.league.slug, division_slug: division.slug)
  end

end