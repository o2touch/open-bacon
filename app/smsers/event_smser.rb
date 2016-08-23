class EventSmser < BaseSmser

  def member_event_created(recipient_id, tenant_id, data)
    event, team, organiser = extract_data(data)

    recipient = User.find(recipient_id)
    to = recipient.mobile_number

    set_locale recipient

    name = recipient.name.nil? ? "Hey there" : recipient.first_name
    time_str =  event.bftime.pp_sms_time
    event_title_str = (event.title.nil? || event.game_type == GameTypeEnum::PRACTICE) ? "" : "#{event.title} "

    body = "NEW: #{team.name} #{event.game_type_string.upcase} - #{event_title_str}#{time_str}"

    sms(to: to, body: body)
    end
    alias_method :parent_event_created, :member_event_created   
    alias_method :player_event_created, :member_event_created   
    alias_method :follower_event_created, :member_event_created 

	def member_event_postponed(recipient_id, tenant_id, data)
    event, team, organiser = extract_data(data)

    recipient = User.find(recipient_id)
    to = recipient.mobile_number

    set_locale recipient

    name = recipient.name.nil? ? "Hey there" : recipient.first_name
    time_str =  event.bftime.pp_sms_time
    event_title_str = (event.title.nil? || event.game_type == GameTypeEnum::PRACTICE) ? "" : "#{event.title} "

    body = "POSTPONED: #{team.name} #{event.game_type_string.upcase} - #{event_title_str}#{time_str}"

    sms(to: to, body: body)
	end
	alias_method :parent_event_postponed, :member_event_postponed	
	alias_method :player_event_postponed, :member_event_postponed	
	alias_method :follower_event_postponed, :member_event_postponed	

	def member_event_rescheduled(recipient_id, tenant_id, data)
    event, team, organiser = extract_data(data)

    recipient = User.find(recipient_id)
    to = recipient.mobile_number

    set_locale recipient

    name = recipient.name.nil? ? "Hey there" : recipient.first_name
    time_str =  event.bftime.pp_sms_time
    event_title_str = (event.title.nil? || event.game_type == GameTypeEnum::PRACTICE) ? "" : "#{event.title} "

    body = "RESCHEDULED: #{team.name} #{event.game_type_string.upcase} - #{event_title_str}#{time_str}"

    sms(to: to, body: body)
	end
	alias_method :parent_event_rescheduled, :member_event_rescheduled	
	alias_method :player_event_rescheduled, :member_event_rescheduled	
	alias_method :follower_event_rescheduled, :member_event_rescheduled	

	def member_event_activated(recipient_id, tenant_id, data)
    event, team, organiser = extract_data(data)

    recipient = User.find(recipient_id)
    to = recipient.mobile_number

    set_locale recipient

    name = recipient.name.nil? ? "Hey there" : recipient.first_name
    time_str =  event.bftime.pp_sms_time
    event_title_str = (event.title.nil? || event.game_type == GameTypeEnum::PRACTICE) ? "" : "#{event.title}"

    body = "ITS BACK ON: #{team.name} #{event.game_type_string.upcase} - #{event_title_str} is back on for #{time_str}"

    # Append text to sms
    append_body = mobile_footer_text(recipient, team)
    body += " - " + append_body if append_body.length > 0

    sms(to: to, body: body)
	end
	alias_method :parent_event_activated, :member_event_activated	
	alias_method :player_event_activated, :member_event_activated	
	alias_method :follower_event_activated, :member_event_activated

	def member_event_cancelled(recipient_id, tenant_id, data)
    event, team, organiser = extract_data(data)

    recipient = User.find(recipient_id)
    to = recipient.mobile_number

    set_locale recipient

    name = recipient.name.nil? ? "Hey there" : recipient.first_name
    time_str =  event.bftime.pp_sms_time
    event_title_str = (event.title.nil? || event.game_type == GameTypeEnum::PRACTICE) ? "" : "#{event.title} "

    body = "CANCELLED - #{team.name} #{event.game_type_string.upcase} - #{event_title_str}#{time_str} has been cancelled"

    # Append text to sms
    append_body = mobile_footer_text(recipient, team)
    body += " - " + append_body if append_body.length > 0

    sms(to: to, body: body)
	end
	alias_method :parent_event_cancelled, :member_event_cancelled	
	alias_method :player_event_cancelled, :member_event_cancelled	
	alias_method :follower_event_cancelled, :member_event_cancelled

	def member_event_updated(recipient_id, tenant_id, data)
    event, team, organiser = extract_data(data)

    recipient = User.find(recipient_id)
    to = recipient.mobile_number

    set_locale recipient

    name = recipient.name.nil? ? "Hey there" : recipient.first_name
    time_str =  event.bftime.pp_sms_time

    event_title_str = (event.title.nil? || event.game_type == GameTypeEnum::PRACTICE) ? "" : "#{event.title} "

    body = "UPDATED - Details about #{team.name} #{event.game_type_string.upcase} - #{event_title_str}#{time_str} have changed"

    # Append text to sms
    append_body = mobile_footer_text(recipient, team)
    body += " - " + append_body if append_body.length > 0

    sms(to: to, body: body)
	end
	alias_method :parent_event_updated, :member_event_updated	
	alias_method :player_event_updated, :member_event_updated	
	alias_method :follower_event_updated, :member_event_updated

  def player_or_parent_event_invite_reminder(recipient_id, tenant_id, data)
    event, team, organiser = extract_data(data)
    recipient = User.find(recipient_id)

    tenant = Tenant.find(tenant_id)
    app_name = I18n.t "general.app_name", locale: tenant.i18n

    tse = TeamsheetEntry.find(data[:tse_id]) 
    I18n.locale = tse.user.locale unless tse.user.locale.nil?
    date_time = tse.event.bftime.pp_sms_time
    sms_reply_code = data[:sms_reply_code]

    # if junior, write to their parent
    if data.has_key? :junior_id
      junior = User.find data[:junior_id]
      body = "#{organiser.name.titleize} via #{app_name}: #{junior.name.titleize} has a game on #{date_time}. Can #{junior.name.titleize} make it? Text back Y#{sms_reply_code} or N#{sms_reply_code}"
    else
      body = "#{organiser.name.titleize} via #{app_name}: #{recipient.name.titleize}, there's a game on #{date_time}. Can you make it? Text back Y#{sms_reply_code} or N#{sms_reply_code}"
    end

    to = recipient.mobile_number
    append_body = mobile_footer_text(recipient, team)
    body += " - " + append_body if append_body.length > 0

    sms(to: to, body: body)
  end
  alias_method :parent_event_invite_reminder, :player_or_parent_event_invite_reminder 
  alias_method :player_event_invite_reminder, :player_or_parent_event_invite_reminder 

  private
  def extract_data(data)
    event = Event.find(data[:event_id])
    team = Team.find(data[:team_id])
    organiser = User.find(data[:actor_id])

    [event, team, organiser]
  end
end
