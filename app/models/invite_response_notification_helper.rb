class InviteResponseNotificationHelper
  
  def after_create(invite_response)
    if invite_response.teamsheet_entry.event.type == "DemoEvent"
    	self.handle_demo_event_after_create(invite_response)
    else
      self.handle_event_after_create(invite_response)
    end
  end

  def handle_event_after_create(invite_response)
    FacebookService.post_play_in_game_action(invite_response.respondent, invite_response.teamsheet_entry, invite_response)
    invite_response.push_create_to_feeds
    invite_response.touch_via_cache
  end

  def handle_demo_event_after_create(invite_response)
  # return as fast as possible is 99% of cases
    return unless invite_response.teamsheet_entry.event.type == "DemoEvent"

    # return slightly slower for 1% of cases... 
    organiser = invite_response.teamsheet_entry.event.organiser
    if invite_response.teamsheet_entry.user == organiser && 
                invite_response.teamsheet_entry.user.type != "DemoUser" &&
                invite_response.teamsheet_entry.invite_responses.count == 1
      DemoService.generate_responses invite_response.teamsheet_entry.event

      unless organiser.get_setting(:completed_event_page)
        organiser.update_setting(:completed_event_page, true)
        organiser.save
        organiser.goals.notify
      end
    end
    invite_response.push_create_to_feeds
    invite_response.touch_via_cache
  end
end