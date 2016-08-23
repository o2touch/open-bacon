class UserSmser < BaseSmser

  def follower_registered(recipient_id, tenant_id, data)
    recipient = User.find(recipient_id)
    to = recipient.mobile_number
    team = Team.find(data[:team_id]) unless data[:team_id].nil?

    name = recipient.name.nil? ? "Hey there" : recipient.first_name

    body = "#{name}, you're now following #{team.name}. You'll receive only the most important updates via text."

    # Append text to sms
    append_body = follower_download_prompt(recipient, team)
    body += append_body if append_body.length > 0

    sms(to: to, body: body)
  end


  def follower_invited(recipient_id, tenant_id, data)
    recipient = User.find(recipient_id)
    team = Team.find(data[:team_id]) unless data[:team_id].nil?

    team_invite = data.has_key?(:team_invite_id) ? TeamInvite.find(data[:team_invite_id]) : nil

    # This text is useless if there is no team invite
    raise StandardError.new("No team invite for UserSmser#follower_invited for recipient #{recipient_id}") if team_invite.nil?

    inviter = team_invite.sent_by

    name = recipient.name.nil? ? "Hey there" : recipient.first_name
    inviter_name = inviter.nil? ? "someone" : inviter.first_name

    to = recipient.mobile_number
    body = "#{name}, #{inviter_name} has invited you to follow #{team.name} on Mitoo. You will now receive updates about fixtures and results."

    # Append text to sms
    append_body = follower_download_prompt(recipient, team)
    body += append_body if append_body.length > 0

    sms(to: to, body: body)
  end

end