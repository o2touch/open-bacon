home_points = { normal: 3, four_try_bonus: 1 }
away_points = { normal: 0, within_seven_bonus: 1 }
FactoryGirl.define do
	factory :points do |f|
		f.strategy { PointsStrategyEnum.values.sample }
		f.home_points home_points
		f.away_points away_points
	end	
end