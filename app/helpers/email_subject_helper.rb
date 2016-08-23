# Helper to return the email subject lines
# This helper has been extensively tested, so ensure to update the tests if you make any changes
module EmailSubjectHelper

  def subject_for_event_schedule(team)
    "#{team.name}'s Schedule"
  end

  def subject_for_event_schedule_update(team, juniors=nil)
    if(juniors.nil?)
      return "Updates to #{team.name}'s Schedule"
    else
      juniors = [juniors] if juniors.is_a?(User) # Now expect an array of juniors
      return "#{juniors.map(&:first_name).to_sentence}\'s schedule has changed"
    end
  end

  def subject_for_user_weekly_schedule(recipient)
    "#{recipient.first_name}, here are the games & events for this week"
  end

  def subject_for_parent_weekly_schedule(recipient, junior)
    "#{recipient.first_name}, here are #{junior.first_name}'s upcoming events"
  end

  def subject_for_invite(event)
    time_str = !event.time.nil? ? event.bftime.pp_time : ""
    "Available at #{time_str}?"
  end

  def subject_for_message_posted(message)
    "#{message.user.name} posted a message"
  end

  def subject_for_comment_posted(comment)
    "#{comment.user.name} posted a comment"
  end

  def subject_for_invite_reminder(event, junior=nil)
    date_str = event.bftime.pp_time
    subject_str = junior.nil? ? "you" : "#{junior.first_name.titleize}"

    "Reminder: Can #{subject_str} play in the #{event.game_type_string(false)} at #{date_str}?"
  end

  def subject_for_event_reminder(event)
    day_of_week = self.day_of_week(event.time, event.time_zone)
    "Don't forget the #{event.game_type_string(false)} #{day_of_week}"
  end

  def subject_for_scheduled_event_reminder_single(event, junior=nil)
    day_of_week = self.day_of_week(event.time, event.time_zone)
    subject_str = junior.nil? ? "You are" : "#{junior.first_name.titleize} is"

    "Reminder: #{subject_str} available for #{event.game_type_string(false, true)} #{day_of_week}"
  end

  def subject_for_scheduled_event_reminder_multiple(tse, all_same_day=true, junior=nil)
    when_str = all_same_day ? " " + self.day_of_week(tse[0].event.time, tse[0].event.time_zone) : ""
    subject_str = junior.nil? ? "You are" : "#{junior.first_name.titleize} is"

    "Reminder: #{subject_str} available for #{tse.size} events#{when_str}"
  end

  def subject_for_event_created(event, junior=nil)

    return "#{junior.first_name.titleize} has a new #{event.game_type_string(false)} coming up" unless junior.nil?

    "You have a new #{event.game_type_string(false)} coming up"
  end

  def subject_for_follower_event_created(event, junior=nil)
    "A new #{event.game_type_string(false)} has been added"
  end

  def subject_for_event_cancelled(event, junior=nil)
    subject_str = junior.nil? ? "Your" : "#{junior.first_name.titleize}'s"
    "#{subject_str} #{event.game_type_string(false)} has been cancelled!"
  end

  def subject_for_event_activated(event, junior=nil)
    subject_str = junior.nil? ? "Your" : "#{junior.first_name.titleize}'s"
    "#{subject_str} #{event.game_type_string(false)} is back on!"
  end

  def subject_for_event_postponed(event, junior=nil)
    subject_str = junior.nil? ? "Your" : "#{junior.first_name.titleize}'s"
    "#{subject_str} #{event.game_type_string(false)} has been postponed!"
  end

  def subject_for_event_rescheduled(event, junior=nil)
    subject_str = junior.nil? ? "Your" : "#{junior.first_name.titleize}'s"
    "#{subject_str} #{event.game_type_string(false)} has been rescheduled!"
  end

  def subject_for_event_details_updated(event, junior=nil)
    subject_str = junior.nil? ? "Your" : "#{junior.first_name.titleize}'s"
    "#{subject_str} #{event.game_type_string(false)} has been updated"
  end

  def subject_for_new_user_invited_to_team(team, junior=nil)
    subject_str = junior.nil? ? "Your" : "#{junior.first_name.titleize}'s"
    "#{subject_str} invitation to join #{team.name} on Mitoo"
  end

  def subject_for_result_created(result, team)

    result_str = "WON" if result.won?(team)
    result_str = "LOST" if result.lost?(team)
    result_str = "DREW" unless result.lost?(team) || result.won?(team)

    score = "#{result.home_final_score_str}:#{result.away_final_score_str}"
    if result.home_final_score_str.to_i < result.away_final_score_str.to_i
      score = "#{result.away_final_score_str}:#{result.home_final_score_str}"
    end

    fixture = result.fixture
    opp_team = fixture.away_team if fixture.home_team==team
    opp_team = fixture.home_team unless fixture.home_team==team

    "#{team.name} #{result_str} #{score} vs #{opp_team.name}"
  end

  def subject_for_div_result_created(fixture)
    "Lastest #{fixture.division_season.title} result: #{fixture.home_team.name} #{fixture.result.to_string} #{fixture.away_team.name}"
  end

  def subject_for_result_updated(fixture)
    "Score updated"
  end

  def subject_for_user_imported(team)
    "New mobile app for #{team.name} powered by Mitoo"
  end

  def subject_for_user_imported_generic(user)
    "#{user.name}, a new mobile app for you powered by Mitoo"
  end

  # PLAYERS
  def subject_for_o2_touch_player_role_created(player)
    "Welcome to O2 Touch, #{player.name}"
  end

  def subject_for_organiser_o2_touch_player_role_created(player, team)
    "New Player: #{player.name} has just joined #{team.name}"
  end

  # FOLLOWERS
  def subject_for_follower_created(recipient, team)
    #SR - this copy is not good due to the poor attention to grammer however I was asked to change this.
    #https://trello.com/c/2RAp80hf/13-faft-mvp-improvements
    "#{recipient.first_name.titleize} You are now following #{team.name} on Mitoo"
  end

  def subject_for_follower_registered(recipient, team)
    #SR - this copy is not good due to the poor attention to grammer however I was asked to change this.
    #https://trello.com/c/2RAp80hf/13-faft-mvp-improvements
    "#{recipient.first_name.titleize} You are now following #{team.name} on Mitoo"
  end

  def subject_for_follower_invited(team, inviter)
    inviter_name = inviter.nil? ? "Someone" : inviter.first_name.titleize
    "#{inviter_name} invited you to follow #{team.name} on Mitoo"
  end

  def subject_for_follower_event_cancelled(event)
    "#{event.game_type_string(false, true).capitalize} has been cancelled!"
  end

  def subject_for_follower_event_activated(event)
    "#{event.game_type_string(false, true).capitalize} is back on!"
  end

  def subject_for_follower_event_postponed(event)
    "#{event.game_type_string(false, true).capitalize} has been postponed!"
  end

  def subject_for_follower_event_rescheduled(event)
    "#{event.game_type_string(false, true).capitalize} has been rescheduled!"
  end

  def subject_for_follower_event_updated(event)
    "#{event.game_type_string(false, true).capitalize} has been updated"
  end

  # METHODS BELOW HAVE NOT BEEN TESTED
  def subject_for_user_registered_confirmation
    "Account Confirmed: You can now download the Mitoo App and more..."
  end

  def subject_for_bluefields_invite
    "Sign up to Mitoo to turbo charge your Sports Team"
  end

  ######
  # LEAGUE MAILER
  ######
  def subject_for_organiser_division_launched(league, team)
    "Welcome to #{league.title}, you are a captain of #{team.name}"
  end

  # Helper method
  def day_of_week(time, time_zone, now=Time.now)
    ((time-now) < 1.day.to_i) ? "tomorrow" : "on " + time.in_time_zone(time_zone).strftime('%A')
  end

end