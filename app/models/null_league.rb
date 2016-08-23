class NullLeague
  def has_organiser?(user)
    false
  end

  def title
    nil
  end

  def logo_medium_url
    nil
  end

  def null?
    true
  end
  #define method missing?
end