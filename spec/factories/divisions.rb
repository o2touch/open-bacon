FactoryGirl.define do
	factory :division_season do |d|
    d.fixed_division
		d.title { fg_division_title }
		d.age_group { fg_age_group }
		d.start_date 3.days.ago
		d.end_date 6.months.from_now
    d.edit_mode 0
    d.track_results true
    d.show_standings true
    d.source_id nil
    d.slug { title.gsub(' ','-').downcase }
    d.current_season true

    after :create do |d, eval|
      d.reload
      d.fixed_division.division_seasons = [d]
      d.fixed_division.current_division_season = d
      d.fixed_division.save
    end

    trait :with_fixtures do |d|
      ignore do
        fixtures_count 5 
      end

      after :create do |d, eval|
        d.fixtures FactoryGirl.create_list(:fixture, eval.fixtures_count, division_season: d)
        d.reload
      end
    end
	end
end