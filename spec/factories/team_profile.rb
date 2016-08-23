FactoryGirl.define do
  factory :team_profile do |t|
	 	t.colour1 { fg_colour }
	 	t.colour2 { fg_colour }
	 	t.sport { fg_sport }
  	t.league_name 'Bluefields'
  	t.age_group AgeGroupEnum::ADULT
  end
end