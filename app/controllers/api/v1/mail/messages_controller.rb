include IncomingMailHelper

class Api::V1::Mail::MessagesController < Api::V1::ApplicationController
	skip_before_filter :authenticate_user!, only: [:create, :bounced]
	skip_authorization_check only: [:create, :bounced]

	respond_to :html 

  def bounced
    user = User.find_by_email(params['recipient'])
    if user
      user.unsubscribe = true
      user.save
    end

    head :ok
  end

	def create
		pretty_print_mail(params)
		# if it's not mailgun do nothing (but pretend it's all 200)
		authed = auth_mailgun(params['timestamp'], params['token'], params['signature'])
		mail_logger.info("    [REJECT] rejecting(200) as not request not authed") unless authed
		head :ok and return unless authed

		auto_response = likely_auto_reponse?(params)
		mail_logger.info("    [REJECT] rejecting(406) as automated message") if auto_response
		head :not_acceptable and return if auto_response

		from = params['sender']
		to = params['recipient']
		comment = params['stripped-text']
		m_id = params['Message-Id']

		@user, @ai = decode_reply_to(to)
		ability = Ability.new(@user)
		fail(from, m_id, "invalid to address") and return if @user.nil? || @ai.nil?
		fail(from, m_id, "invalid AI type") and return unless @ai.obj.is_a?(EventMessage) || @ai.obj.is_a?(InviteResponse)
		fail(from, m_id, "incorrect from address") and return unless @user.email == from
		fail(from, m_id, "unauthorized") and return unless ability.can? :comment_via_email, @ai.obj

		# actually make the comment
    @aic = @ai.create_comment(@user, comment)
    @aic.send_notifications

    mail_logger.info("    success(200)")
    # success
		head :ok
	end


	private

	def mail_logger
    @@mail_logger ||= Logger.new("#{Rails.root}/log/incoming_mail.log")
  end

  def pretty_print_mail(params)
  	mail_logger.info("\n*** NEW MAIL ***:")
  	params.each do |k, v|
			v.gsub!(/\n/,"\n        ") if v.is_a? String
  		mail_logger.info("        #{k}: #{v}")
  	end
  end

	def fail(from, message_id, reason)
    EventNotificationService.send_comment_from_email_failure(from, message_id)
    mail_logger.info("    sending failure email")
		mail_logger.info("    rejecting(406) as #{reason}")
	  head :not_acceptable
	end

  # try and detect (very simply) if the status belongs to an auto-gened email.
  def likely_auto_reponse?(params)
		auto_header = params['Auto-Submitted'] || ""
		subject = params['subject'] || ""

  	subject_phrases = ["out of office", "out of the office", "autoreply", "delivery status notification", "message status - undeliverable"]

  	if !auto_header.nil? && !auto_header.blank? && auto_header != "no"
  		mail_logger.info("    Auto-Submitted header == #{auto_header}")
  		return true
  	end

  	subject_phrases.each do |phrase|
  		if subject.downcase.include? phrase
  			mail_logger.info("    subject contains #{phrase}")
  			return true
  		end
  	end

  	false
  end
end