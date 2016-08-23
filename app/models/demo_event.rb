class DemoEvent < Event

  def touch_via_cache(time=self.updated_at)
    time = time.utc
    self.organiser.events_last_updated_at = time unless self.organiser.nil?
    users.each {|user| user.events_last_updated_at = time }
    self.team.events_last_updated_at = time unless self.team.nil?
    return true
  end

  def demo_event?
  	true
  end
end
