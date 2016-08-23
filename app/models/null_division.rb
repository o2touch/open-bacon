class NullDivision
  def league
    NullLeague.new
  end

  alias_method :graceful_league, :league
end