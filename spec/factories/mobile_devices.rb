FactoryGirl.define do
	factory :mobile_device do |m|
		m.user
		m.token "tokenaksdjhfaksjhf"
		m.active true
		m.logged_in true
		m.platform MobilePlatformEnum::IOS
		m.model "iPhone 5S"
		m.os_version "7"	
		m.app_version "1.0.2"
		m.mobile_app_id 1
	end
end