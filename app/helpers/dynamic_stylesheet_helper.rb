module DynamicStylesheetHelper

  def team_stylesheet_path(team=nil)
    s = TeamStylesheet.new(team)
    s.compile unless s.compiled?
    "/assets/#{s.stylesheet_file}"
  end

end