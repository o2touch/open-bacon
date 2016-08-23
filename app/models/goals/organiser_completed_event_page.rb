class OrganiserCompletedEventPage < GoalCheckListItem

  def initialize(user)
    @user = user
  end

  def complete?
    @user.get_setting(:completed_event_page)
  end
  
end
