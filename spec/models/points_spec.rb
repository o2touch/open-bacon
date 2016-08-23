require 'spec_helper'

describe Points do
	describe 'validations' do
		before :each do
			@points = FactoryGirl.build :points
		end

		it 'is valid from factory girl' do
			@points.should be_valid
		end
		it 'must have a valid strategy' do
			@points.strategy = "kahfs"
			@points.should_not be_valid

			@points.strategy = nil
			@points.should_not be_valid
		end
		it 'must have numeric points' do
			@points.home_points[:some_kind_of_points] = "hi"
			@points.should_not be_valid
		end
		it 'must only have points defined on div, if has fixgture and div' do
			@points.stub(fixture: double(division: double(points_categories: { full_time: "hiii" } )))
			@points.home_points = { not_full_time: 2 }
			@points.should_not be_valid
		end
	end

	describe '#total_home_points' do
		it 'returns 0 if empty hash' do
			home_points = {}
			@points = FactoryGirl.build :points, home_points: home_points
			@points.total_home_points.should eq(0)
		end
		it 'adds up everything in the hash' do
			home_points = { normal: 3, four_try_bonus: 1 }
			@points = FactoryGirl.build :points, home_points: home_points
			@points.total_home_points.should eq(4)
		end
	end

	describe '#total_away_points' do
		it 'returns 0 if empty hash' do
			away_points = {}
			@points = FactoryGirl.build :points, away_points: away_points
			@points.total_away_points.should eq(0)
		end
		it 'adds up everything in the hash' do
			away_points = { normal: 0, within_seven_bonus: 1 }
			@points = FactoryGirl.build :points, away_points: away_points
			@points.total_away_points.should eq(1)
		end
	end
end