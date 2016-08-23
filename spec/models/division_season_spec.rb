require 'spec_helper'

describe DivisionSeason do

	describe 'past_fixtures' do
		it 'should return fixtures prior to and including the specified time' do
			d = FactoryGirl.build :division_season, :with_fixtures
			
			fixtures = [
				FactoryGirl.create(:fixture, division_season: d, time: 3.days.ago),
				FactoryGirl.create(:fixture, division_season: d, time: 2.days.ago),
				FactoryGirl.create(:fixture, division_season: d, time: 1.days.ago),
				FactoryGirl.create(:fixture, division_season: d, time: 1.days.from_now),
				FactoryGirl.create(:fixture, division_season: d, time: 2.days.from_now),
				FactoryGirl.create(:fixture, division_season: d, time: 3.days.from_now)
			]

			fixtures.map(&:publish_edits!)

			d.past_fixtures.map(&:id).should == fixtures[0..2].sort_by(&:time).map(&:id)
			d.past_fixtures(2.days.ago).map(&:id).should == fixtures[0..1].sort_by(&:time).map(&:id)
		end

		it 'should return empty if fixtures are unpublished' do
			d = FactoryGirl.build :division_season, :with_fixtures

			FactoryGirl.create(:fixture, division_season: d, time: 3.days.ago)

			d.past_fixtures.should == []
		end
	end

	describe 'future_fixtures' do
		it 'should return fixtures after the specified time' do
			d = FactoryGirl.build :division_season, :with_fixtures
			
			fixtures = [
				FactoryGirl.create(:fixture, division_season: d, time: 3.days.ago),
				FactoryGirl.create(:fixture, division_season: d, time: 2.days.ago),
				FactoryGirl.create(:fixture, division_season: d, time: 1.days.ago),
				FactoryGirl.create(:fixture, division_season: d, time: 1.days.from_now),
				FactoryGirl.create(:fixture, division_season: d, time: 2.days.from_now),
				FactoryGirl.create(:fixture, division_season: d, time: 3.days.from_now)
			]

			fixtures.map(&:publish_edits!)

			d.future_fixtures.map(&:id).should == fixtures[3..-1].sort_by(&:time).map(&:id)
			d.future_fixtures(2.days.from_now).map(&:id).should == [fixtures[5].id]
		end

		it 'should return empty if fixtures are unpublished' do
			d = FactoryGirl.build :division_season, :with_fixtures

			FactoryGirl.create(:fixture, division_season: d, time: 3.days.from_now)

			d.future_fixtures.should == []
		end
	end

	describe 'validations' do
		before :each do
			@division = FactoryGirl.build :division_season
		end

		it 'is valid when valid' do
			@division.should be_valid
		end
		# TODO: ensure this test passes, once fixed divisions are alls et up.
		it 'must belong to a fixed_division' do
			@division.fixed_division = nil
			@division.should_not be_valid
		end
		it 'requires a title' do
			@division.title = nil
			@division.should_not be_valid
		end
		it 'requires an age group' do
			@division.age_group = nil
			@division.should_not be_valid
		end
		it 'requires an age group in the AgeGroupEnum' do
			@division.age_group = "10000000"
			@division.should_not be_valid
		end
		it 'requires a start date' do
			@division.age_group = nil
			@division.should_not be_valid
		end
		it 'requires the start date is before the end date' do
			@division.start_date = 1.year.from_now
			@division.end_date = 1.year.ago
			@division.should_not be_valid
		end
		it 'requires scoring system to be in ScoringSystemEnum' do
			@division.scoring_system = "Kabaddi"
			@division.should_not be_valid
		end
	end

	describe 'fixtures_to_display' do
		it 'only displays fixtures to display'
	end

	describe 'publish_edits' do
		it 'publishes shit' do
			@user = FactoryGirl.create(:user)
			@division = double("division")
			@fixtures = (1..5).map{ |i| double("fixture #{i}") }
			@fixtures.each { |f| f.should_receive(:publish_edits!) }
			@division.should_receive(:fixtures).and_return(@fixtures)
			@division.should_receive(:update_attributes!).with({edit_mode: 0})
			DivisionSeason.stub!(find: @division)
			AppEventService.should_receive(:create).with(@division, @user, "published")
			DivisionSeason.publish_edits!(1, @user.id)
		end
	end

	describe 'launch!' do
		it 'returns false if it has alredy been launched' do
			@division = FactoryGirl.build :division_season
			@division.launched = true
			DivisionSeason.stub(find: @division)
			DivisionSeason.launch!(1, 1).should be_false
		end
		it 'creates an app event' do
			@division = FactoryGirl.build :division_season
			DivisionSeason.stub(find: @division)
			AppEventService.should_receive(:create).with(@division, kind_of(User), "launched")
			DivisionSeason.launch!(1, 1).should be_true
		end
	end

	describe 'find_by_mitoo_id' do
		it 'exists' do
			expect { DivisionSeason.find_by_mitoo_id(1) }.to_not raise_error
		end
	end

	# Corresponding code is currently commented
	# describe 'clear_edits' do
	# 	it 'clcears all the edits in all the fixtures' do
	# 		@division = double("division")
	# 		@fixtures = (1..5).map{ |i| double("fixture #{i}") }
	# 		@fixtures.each { |f| f.should_receive(:clear_edits!) }
	# 		@division.should_receive(:fixtures).and_return(@fixtures)
	# 		@division.should_receive(:update_attributes!).with({edit_mode: 0})
	# 		Division.stub!(find: @division)
	# 		Division.clear_edits!(1)
	# 	end
	# end
end