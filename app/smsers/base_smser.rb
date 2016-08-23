class BaseSmser
	include Rails.application.routes.url_helpers
	include LocaleHelper
	include SmserHelper

	def sms(attrs)
		to = attrs[:to]
		body = attrs[:body]

		return NullSms.new if to.blank? || body.blank?

		# SENDING SMSs is *FUCKED* it causes openssl to segfault if more than one is
		#         sent at the same time. WHAT THE FUUUUUUUUUUUUCK. TS
		#return NullSms.new
		Sms.build(to, body)
	end

	class << self
		protected
		# a simplified version of the fucked up shit that allows you to call
		# instance methods as though they were class methods in ActionMailer. TS
	  def method_missing(method_name, *args)
	  	if public_instance_methods.include? method_name
	  		new.send(method_name, *args)
	  	else
	  		super
	  	end
	  end

  end
end