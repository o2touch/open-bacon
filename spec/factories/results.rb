
football_home_score = { first_quarter: '3', second_quarter: '3', third_quarter: '3', fourth_quarter: '0', over_time: '14', final: '22' }
football_away_score = { first_quarter: '2', second_quarter: '8', third_quarter: '7', fourth_quarter: '5', over_time: '0', final: '23' }
FactoryGirl.define do
	factory :football_result do |f|
		f.fixture 
		f.home_score football_home_score
		f.away_score football_away_score
	end
end

soccer_away_score = { first_half: 1, second_half: 0, full_time: 1 }
soccer_home_score = { first_half: 0, second_half: 2, full_time: 2 }
FactoryGirl.define do
	factory :soccer_result do |f|
		f.fixture 
		f.home_score soccer_home_score
		f.away_score soccer_away_score
	end
end