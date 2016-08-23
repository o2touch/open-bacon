FactoryGirl.define do
	sequence(:slug_uniqifier) { |n| "#{n}"}

	factory :league do |l|
		l.title { fg_league_title }
		l.slug { "#{title.gsub(/[\W]+/, "").first(19)}#{generate(:slug_uniqifier)}" } 
		l.region { fg_region }
		l.time_zone { TimeZoneEnum.values.sample }
		l.sport { fg_sport }
		l.colour1 { fg_colour }
		l.colour2 { fg_colour }

		after :create do |l, evaluator|
			u = FactoryGirl.create(:user)
			l.add_organiser u
		end
	end
end