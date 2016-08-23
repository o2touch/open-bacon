class JuniorMailerService
  
  class << self
    include EventUpdateHelper

    # Commented methods correspond to events migrated out of the EventNotificationService
    #    the functionality of the methods below, has therefore been included in the
    #    relevant processor.

    def event_upcoming_reminder(teamsheet_entry)
      return unless teamsheet_entry.user.should_send_email? #push logic up chain?
      deliver(:event_upcoming_reminder, teamsheet_entry.user, teamsheet_entry.event.id, event.organiser.id)
    end

    def parent_invited_to_team(team_invite)
      team_invite_token = team_invite.token
      team = team_invite.team
      parent = team_invite.sent_to
      organiser_id = team_invite.sent_by_id 
      junior_ids = team.player_ids & parent.child_ids

      JuniorMailer.delay.parent_invited_to_team(parent.id, team.id, junior_ids, organiser_id, team_invite_token)
    end

    def event_schedule(team_invite, updated_events)
      return unless updated_events.count > 0 #push logic up chain?
      team_invite_token = team_invite.token
      team = team_invite.team
      parent = team_invite.sent_to
      organiser_id = team_invite.sent_by_id 
      junior_ids = team.player_ids & parent.child_ids
      event_ids = updated_events.map(&:id)
      
      JuniorMailer.delay.event_schedule(parent.id, team.id, junior_ids, organiser_id, event_ids, team_invite_token)
    end

    def scheduled_event_reminder_multiple(junior, teamsheet_entries)
      comparison_event = teamsheet_entries.first
      same_day = teamsheet_entries.all? { |tse| BFTimeLib.same_day?(tse, comparison_event) }
      teamsheet_entry_ids = teamsheet_entries.map(&:id)
      deliver(:scheduled_event_reminder_multiple, junior, teamsheet_entry_ids, same_day)
    end

    def scheduled_event_reminder_single(junior, teamsheet_entry)
      deliver(:scheduled_event_reminder_single, junior, teamsheet_entry.id)
    end

    def invite_reminder(junior, invite_reminder)
      deliver(:invite_reminder, junior, invite_reminder.id)
    end

  private
    def get_team_invite(team, user)
      TeamInvite.find(:first, conditions: { team_id: team.id, sent_to_id: user.id })
    end

    def deliver(mail, junior, *args)
      junior.parents.select(&:should_send_email?).each do |parent|
        JuniorMailer.delay.send(mail, parent.id, junior.id, *args)
      end
    end
  end
end
