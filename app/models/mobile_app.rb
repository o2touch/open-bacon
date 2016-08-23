# This model represents the mobile apps we have in app stores. Really they're just
#  so we have somewhere to stick details needed to get a notification to arrive. TS
class MobileApp < ActiveRecord::Base

	has_many :mobile_devices
	has_many :tenants

	attr_accessible :name, :token

	#allabitshit TS
	def ua_app_secret
		"#{self.name.gsub(/ /, "_").upcase}_APPLICATION_SECRET".constantize
	end

	def ua_app_key
		"#{self.name.gsub(/ /, "_").upcase}_APPLICATION_KEY".constantize
	end

	def ua_master_secret
		"#{self.name.gsub(/ /, "_").upcase}_MASTER_SECRET".constantize
	end
end