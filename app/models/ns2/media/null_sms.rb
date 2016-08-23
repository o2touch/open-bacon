class NullSms
	def to; '' end
	def body; '' end

	def deliver
		raise "cannot devlier a NullSms"
	end

	def null_sms?
		true
	end
end
