FactoryGirl.define do
	factory :fixed_division do |fd|
		fd.league
		fd.division_seasons []
		fd.current_division_season nil
	end
end
