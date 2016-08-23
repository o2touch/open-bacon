# I might add this shit to one of the other helpers, but leaving here until
#  I know exactly what it's going to become, and how self contained it is.
module IncomingMailHelper
	def encode_reply_to(user, ai)
		raise "user cannot be nil" if user.nil?
		raise "activity item cannot be nil" if ai.nil?
		token = user.incoming_email_token
		raise "user incoming_email_token must not be nil" if token.nil?

		version = 1
		model_id = ai.id
		model_type = "ai" # currently it can only be an activity item.	
		return "#{version}_#{token}_#{model_type}_#{model_id}@reply.mitoo.co"
	end

	def decode_reply_to(address)
		if address.blank?
			Rails.logger.warn("Invalid imcoming email address format: #{address}")
			return nil
		end

		tokens = address.split("@")[0].split("_")
		if tokens.count != 4
			Rails.logger.warn("Invalid imcoming email address format: #{address}")
			return nil
		end

		version = tokens[0]
		user = User.find_by_incoming_email_token(tokens[1])
		model_type = tokens[2] # for now we know this is ai
		model = ActivityItem.find_by_id(tokens[3].to_i)

		if version != "1" || user.nil? || model_type != "ai" || model.nil?
			Rails.logger.warn("Invalid imcoming email address format: #{address}")
			return nil
		end

		return user, model
	end

	# get the value of the message-id header for an email sent/to be sent
	#  for a user and model.
	#  These have to be globally unique. We are currently using the following 
	#  schema. It assume we only ever send out an email about an object once
	#  (where we need to supply message ids). This schema is good, as we can
	#  always work out what it was without db lookups etc. In future we may 
	#  need more complexity/to store values in db etc. but for now this is enough. TS
	# <[SCHEMA_VERSION].[MODEL_TYPE].[MODEL_CREATED_AT.to_i].[MODEL_ID].[SENT_TO_ID]@mitoo.co>
	def encode_message_id(user, model)
		raise "user cannot be nil" if user.nil?
		raise "model cannot be nil" if model.nil?

		version = 1
		model_type = "m" if model.is_a? EventMessage
		model_type = "ir" if model.is_a? InviteResponse
		return nil if model_type.nil? # the above are all we handle so far
		created_at = model.created_at.to_i
		model_id = model.id
		user_id = user.id

		return "<#{version}.#{model_type}.#{created_at}.#{model_id}.#{user_id}@mitoo.co>"
	end

	# check that a request from mailgun actually is from mailgun
	def auth_mailgun(timestamp, token, signature)
    api_key = MAILGUN_API_KEY

    hexdigest = OpenSSL::HMAC.hexdigest(OpenSSL::Digest::Digest.new('SHA256'), api_key, [timestamp, token].join)
    hexdigest.eql?(signature) or false
  end

end