FactoryGirl.define do
	factory :club do |c|
		c.name "Las Vegas Irish RFC"
		c.association :profile, :factory => :team_profile
		c.association :location
	end
end