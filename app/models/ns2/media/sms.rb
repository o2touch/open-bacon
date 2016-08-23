class Sms

	# TODO: change to twilio numbers, if wishing to re-enable
	US_PROD = "+15555555555"
	UK_PROD = "+445555555555555"
	
	US_STAGING = "+155555555555555"
	US_STAGING_TO_NUMBER = "+15555555555"

	DEV = "+1555555555"

	# STAGING = Twilio::Config::USE_STAGING_NUMBER && Rails.env.staging?

	@@twilio_client

	attr_accessor :to, :body

	def self.build(to, body)
		sms = Sms.new
		sms.to = to
		sms.body = body
		sms
	end

	# Do not rescue if shit is fucked... It is caught higher up.
	def deliver
		raise "invalid recipient number" unless validish_number?(@to)
		raise "body must not be blank" if @body.blank?

		from = select_from_number
		to = @to
		to = US_STAGING_TO_NUMBER if STAGING == true # send to staging phone instead...

		# TODO: uncomment if wishing to re-enable
		# @@twilio_client ||= Twilio::REST::Client.new(Twilio::Config::SID, Twilio::Config::TOKEN)
		r = @@twilio_client.account.messages.create({
			from: from,
			to: to,
			body: @body
		})

		transaction_data = {
			created_at: r.date_created,
			to: r.to,
			from: r.from,
			body: r.body,
			status: r.status,
			sid: r.sid
		}

		return transaction_data
	end

	private
	# choose the number we're sending form
	def select_from_number
		return US_STAGING if STAGING == true
		return DEV unless Rails.env.production?

		number = US_PROD
		number = UK_PROD if @to.match(/\+44(.)/)

		number
	end

	# check the number is not wildly invalid
	def validish_number?(number)
		return false if number.blank?
		return false if number.size < 5
		return false unless number[0] == '+'
		true
	end

end

