class ScheduledNotificationMailer < ActionMailer::Base
	include EmailSubjectHelper
	include MailerHelper

    helper :km

	layout 'notifier'

	def user_weekly_event_schedule(recipient_id, tenant_id, data)
    @tenant = Tenant.find(tenant_id)

    # weird shit is to keep the order of the events
    @events = Event.find(data[:event_ids], :order => "field(id, #{data[:event_ids].join(',')})")
    return if @events.count == 0 # will only happen if deleted between creating SK job and here

    @recipient = User.find(recipient_id)
    @time_until = data[:time_until]
    @signup = data.has_key? :new_sign_up
    if !@recipient.is_registered?
      path = "#{user_path(@recipient)}#user/#{@recipient.id}/schedule" # user shchedule page
      @token = PowerToken.generate_token(path, @recipient)
    end

    from = determine_mail_from_for_general_notifications(@tenant)
    to = format_email_to_user(@recipient)
    subject = subject_for_user_weekly_schedule(@recipient)

    mail(from: from, to: to, subject: subject)
	end

	def parent_weekly_event_schedule(recipient_id, tenant_id, data)
    @tenant = Tenant.find(tenant_id)

	# weird shit is to keep the order of the events
    @events = Event.find(data[:event_ids], :order => "field(id, #{data[:event_ids].join(',')})")
    return if @events.count == 0 # will only happen if deleted between creating SK job and here
    @recipient = User.find(recipient_id)

    @junior = User.find(data[:junior_id])
    @time_until =  data[:time_until]
    @signup = data.has_key? :new_sign_up
    if !@recipient.is_registered?
      path = "#{user_path(@junior)}#user/#{@junior.id}/schedule" # junior's shchedule page
      @token = PowerToken.generate_token(path, @recipient)
    end

    from = determine_mail_from_for_general_notifications(@tenant)
    to = format_email_to_user(@recipient)
    subject = subject_for_parent_weekly_schedule(@recipient, @junior)

    mail(from: from, to: to, subject: subject)
	end
end