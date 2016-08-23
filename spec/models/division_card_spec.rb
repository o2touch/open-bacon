require 'spec_helper'

describe DivisionCard do

	describe '#to_json' do
		it 'only returns 5 results' do
			@division = stub_model(DivisionSeason, id: 10876)
			@team = FactoryGirl.build(:team)
			@league = double("league")
			@fixtures = (1..10).map{ |i| stub_model(Fixture, id: i) }

			@division.should_receive(:id).and_return(1)
			@league.should_receive(:id).and_return(1)
			@division.should_receive(:league).and_return(@league)
			@division.should_receive(:past_fixtures).and_return(@fixtures)

			division_card = DivisionCard.new(@division)
			division_card.team = @team
			json = division_card.to_json

			json[:data][:fixtures].size.should == 5
		end

		it 'handles fixtures with no results' do
			@division = stub_model(DivisionSeason, id: 10876)
			@team = FactoryGirl.build(:team)
			@league = double("league")
			@fixtures = (1..5).map{ |i| stub_model(Fixture, id: i, result: nil) }

			@division.should_receive(:id).and_return(1)
			@league.should_receive(:id).and_return(1)
			@division.should_receive(:league).and_return(@league)
			@division.should_receive(:past_fixtures).and_return(@fixtures)

			division_card = DivisionCard.new(@division)
			division_card.team = @team
			json = division_card.to_json

			json[:data][:fixtures].size.should == 5
		end
	end

end