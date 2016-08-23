class EventMessageHelper

  def create_activity_item(event_message)
    activity_item = ActivityItem.new
    activity_item.subj = event_message.user
    activity_item.obj = event_message
    activity_item.verb = :created
    activity_item.save!
  end

  def push_create_to_feeds(event_message)
    clazz = nil
    if event_message.messageable.is_a? Event
      clazz = EventMessage
    elsif event_message.messageable.is_a? Team
      clazz = TeamMessage
    elsif event_message.messageable.is_a? DivisionSeason
      clazz = DivisionMessage
    end
      
    clazz.push_to_feeds(event_message.activity_item, event_message) unless clazz.nil?
  end

  class DivisionMessage
    class << self
      def push_to_feeds(activity_item, event_message)
        division = event_message.messageable
        division.teams.each do |team|
          activity_item.push_to_profile_feed(team)
        end
        activity_item.push_to_profile_feed(division)
      end
    end
  end

  class TeamMessage
    class << self
      def push_to_feeds(activity_item, event_message)
        team = event_message.messageable
        activity_item.push_to_profile_feed(event_message.user)
        activity_item.push_to_profile_feed(team) 
        activity_item.push_to_newsfeeds

        users = event_message.recipients_hash_to_user(event_message.meta_data['recipients'])
      end
    end
  end

  class EventMessage
    class << self
      def push_to_feeds(activity_item, event_message)
        event = event_message.messageable
        activity_item.push_to_profile_feed(event_message.user)
        activity_item.push_to_profile_feed(event.team)
        activity_item.push_to_activity_feed(event)

        unless event.instance_of? DemoEvent
          activity_item.push_to_newsfeeds 
          users = event_message.recipients_hash_to_user(event_message.meta_data['recipients'])
        end
      end
    end
  end
end
