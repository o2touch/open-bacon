class EventPostponedProcessor
  def initialize(name)
    @name = name
  end

  #TODO We dont support juniors leagues
  def process(notification_item)
    return false unless can_process?(notification_item)

    event = notification_item.obj
    user = notification_item.subj
    
    event.invitees.each do |u|
      UserMailer.delay.event_postponed(event.id, u.id, user.id)
      u.mailbox.deliver_message(nil, u, notification_item, UserMailer.name, 'event_postponed')
    end
    
    true
  end

  private
  def can_process?(item)
    #Performance critical code block
    item.verb == VerbEnum::POSTPONED and item.obj_type == Event.name and item.subj_type == User.name
  end
end
