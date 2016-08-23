FactoryGirl.define do
	factory :fixture do |f|
		f.division_season
		f.time_tbc false
		f.time (1..10).to_a.sample.days.from_now
		f.time_zone TimeZoneEnum.values.sample
		f.status EventStatusEnum::NORMAL
	    f.home_team nil
	    f.away_team nil
	    f.location # TODO: This does not work with fixtures very well - PR
	end	
end