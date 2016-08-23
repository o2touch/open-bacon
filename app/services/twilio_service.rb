class TwilioService
	class << self

		def send_junior_event_invitation(tse)
			TwilioService.send_event_invitation(tse, true)
		end

		def send_download_link(recipient_number)

			message = "Install the Mitoo app by going to: #{Rails.application.routes.url_helpers.app_install_url}"

			TwilioService.send_sms(recipient_number, message)
		end

		# def send_event_invitation(tse, is_junior=false)
		# 	return false if tse.nil?
		# 	return false unless validish_number? tse.user.mobile_number

		# 	sms_reply_code   = SmsSent.next_sms_reply_code(tse.user)
		# 	organiser = tse.event.user.name

		# 	user_reply_code = sms_reply_code
		# 	user_reply_code = "" if user_reply_code == 0

		# 	if is_junior
		# 		recipient_number = tse.user.parent.mobile_number
		# 		recipient = tse.user.parent.name
		#     I18n.locale = tse.user.parent.locale unless tse.user.parent.locale.nil?
		# 		date_time = tse.event.bftime.pp_sms_time
		# 		player = tse.user
		#     message = "#{organiser} via Mitoo: #{player.name}, has a game on #{date_time}. Can #{player.name} make it? Text back Y#{user_reply_code} or N#{user_reply_code}"
		# 	else
		# 		recipient_number = tse.user.mobile_number
		# 		recipient = tse.user.name
		#     I18n.locale = tse.user.locale unless tse.user.locale.nil?
		# 		date_time = tse.event.bftime.pp_sms_time
		#     message = "#{organiser} via Mitoo: #{recipient}, there's a game on #{date_time}. Can you make it? Text back Y#{user_reply_code} or N#{user_reply_code}"
		# 	end

	 #    twilio_number = TwilioService.send_sms(recipient_number, message)

	 #    if !twilio_number.nil?
		# 		SmsSent.create!({
		# 			:from => twilio_number, 
		# 			:to => recipient_number,
		# 			:content => message, 
		# 			:teamsheet_entry_id => tse.id,
		# 			:user_id => tse.user.id,
		# 			:sms_reply_code => sms_reply_code
		# 		})
		# 	end
		# 	true
		# end


		# responds with the number twilio used to send the request
		def send_sms(recipient_number, message)		

	    if Rails.env.production?
	      if(recipient_number.match(/\+44(.)/))
	        Rails.logger.debug("Using UK number")
	        twilio_number = "+442033222613"
	      else
	        Rails.logger.debug("Using US number")
	        twilio_number = "+15304195410"
	      end
	    else
	      if(recipient_number.match(/\+44(.)/))
	        Rails.logger.debug("Using (dev) UK number")
	        twilio_number = "+15005550006"
	      else
	        Rails.logger.debug("Using (dev) US number")
	        twilio_number = "+15005550006"
	      end
	    end

	    begin
	      twilio_client = Twilio::REST::Client.new Twilio::Config::SID, Twilio::Config::TOKEN
	      twilio_client.account.messages.create(
	        :from => twilio_number,
	        :to => recipient_number,
	        :body => message
	      )
	    rescue Twilio::REST::RequestError => e
	      Rails.logger.info "Failed to send SMS"
	      Rails.logger.info e.to_yaml
	      return nil
	    end

      return twilio_number
		end

		private

		def validish_number?(number)
			return false if number.blank?
			return false if number.size < 5
			return false unless number[0] == '+'
			true
		end

	end
end