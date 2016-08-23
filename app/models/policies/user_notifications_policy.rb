#####
# USER NOTIFICATIONS POLICY
# Determines if a user should be sent notifications at all
#####
class UserNotificationsPolicy

	def initialize(user, tenant)
    @user = user
    @tenant = tenant

    user_push = @user.pushable_mobile_devices(@tenant).count > 0
    tenant_push = !@tenant.mobile_app.nil?
    
    @email = !@user.email.blank? & @tenant.email
   	@sms = !@user.mobile_number.blank? & @tenant.sms
   	@push = user_push & tenant_push
	end

	def should_notify?
		true
	end

	def can_push?
		@push
	end

	def can_email?
		@email
	end

	def can_sms?
		@sms
	end

	def should_push?
		@push
	end

	def should_email?
		@email && !@push
	end

	def should_sms?
		@sms && !@push && !@email
	end

	def primary_medium?
		return :push if @push
		return :email if @email
		return :sms if @sms
		# should never happen, as one of the above is required....
		raise "Cannot communicate with user #{self.id}"
	end
end