FactoryGirl.define do
	factory :location do |l|
		l.title { ['The Country Ground', 'Sam Boyd Field', 'The Britania Stadium', 'Twickenham', 'Millenium Statium', 'Murreyfield', 'Stade de France', 'Stadio Flamino'].sample }
		l.address { ['1 Edward Ave, ST5 2HB, England', '55 Shepherds Hill, N6 5QP, England', '353 Bonneville Ave, 89101, USA', '23 Girdlestone Walk, N19 5DL, England'].sample }
		
    trait :with_coordinates do
      l.lat { (rand * 180) - 90 }
  		l.lng { (rand * 360) - 180 }
    end
	end	
end