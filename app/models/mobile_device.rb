# This model actually represents more of an app installation, rather than an
#  actual device. The distinction is now important because we have multiple 
#  mobile apps. If a user had both apps on the same phone there would be two
#  of these models to represent that. TS
class MobileDevice < ActiveRecord::Base

	belongs_to :user
	belongs_to :mobile_app

	attr_accessible :user, :token, :active, :logged_in, :platform, :model
	attr_accessible :app_version, :os_version, :mobile_app_id

	validates :user, :token, presence: true
	validates :platform, presence: true, inclusion: { in: MobilePlatformEnum.values }

	def pushable?
		self.logged_in? && self.active?
	end

	def is_ios?
		self.platform == MobilePlatformEnum::IOS
	end

	def is_android?
		self.platform == MobilePlatformEnum::ANDROID
	end
end