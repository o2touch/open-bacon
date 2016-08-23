require 'spec_helper'

describe SoccerResult do
	describe 'validatiosn' do
		before :each do
			away_score = { first_half: '1', second_half: '0', full_time: '1' }
			home_score = { first_half: '0', second_half: '2', full_time: '2' }
			@result = FactoryGirl.build :soccer_result, home_score: home_score, away_score: away_score
		end

		it 'is valid from factory girl' do
			@result.should be_valid
		end
		it 'must have a home score' do
			@result.home_score = nil
			@result.should_not be_valid
		end
		it 'must have an away score' do
			@result.away_score = nil
			@result.should_not be_valid
		end
		it 'must have neither or both first half scores set' do
			@result.home_score[:first_half] = nil
			@result.should_not be_valid
			@result.away_score[:first_half] = nil
			@result.should be_valid
		end
		it 'must have neither or both second half scores set' do
			@result.home_score[:second_half] = nil
			@result.should_not be_valid
			@result.away_score[:second_half] = nil
			@result.should be_valid
		end
		it 'must have both full time scores set' do
			@result.home_score[:full_time] = nil
			@result.should_not be_valid
			@result.away_score[:full_time] = nil
			@result.should_not be_valid
		end
		it 'must have all scores must be integers' do
			@result.home_score[:first_half] = "cat"
			@result.should_not be_valid
			@result.home_score[:first_half] = 1.5
			@result.should_not be_valid
		end
		it 'must have all scores greater or equal to zero' do
			@result.home_score[:first_half] = -1
			@result.should_not be_valid
		end
		it 'must not have invalid score types' do
			@result.home_score[:fourth_quarter] = 100
			@result.should_not be_valid
		end
	end

	describe '#winning_team' do
		it 'returns the winning_team if there was a winner' do
			@home_team = FactoryGirl.build :team
			away_score = { first_half: 1, second_half: 0, full_time: 1 }
			home_score = { first_half: 0, second_half: 2, full_time: 2 }
			@result = FactoryGirl.build :soccer_result, home_score: home_score, away_score: away_score
			@result.stub(home_team: @home_team)

			@result.winning_team.should eq(@home_team)
		end
		it 'return nil if it was a draw' do
			away_score = { first_half: 0, second_half: 0, full_time: 0 }
			home_score = { first_half: 0, second_half: 0, full_time: 0 }
			@result = FactoryGirl.build :soccer_result, home_score: home_score, away_score: away_score

			@result.winning_team.should be_nil
		end
	end

	describe '#=home_score' do
		before :each do
			@sr = SoccerResult.new
		end
		it 'assigns nonsense if I give it nonsense' do
			nonsense = { "cat" => "hey bobby, what's the hap?", full_half: "gigi", will: 1 }
			@sr.home_score = nonsense
			@sr.home_score.should eq(nonsense)
		end
		it 'assigns nil if I give it nil' do
			@sr.home_score = nil
			@sr.home_score.should be_nil
		end
		it 'turns string numbers to ints if I give it ints' do
			string_score = { first_half: '1' , second_half: '3', full_time: '4' }
			int_score = { first_half: 1 , second_half: 3, full_time: 4 }

			@sr.home_score = string_score	
			@sr.home_score.should eq(int_score)
		end
		it 'assings ints if I give it ints' do
			int_score = { first_half: 1 , second_half: 3, full_time: 4 }

			@sr.home_score = int_score	
			@sr.home_score.should eq(int_score)
		end
	end

	describe '#=away_score' do
		before :each do
			@sr = SoccerResult.new
		end
		it 'assigns nonsense if I give it nonsense' do
			nonsense = { "cat" => "hey bobby, what's the hap?", full_half: "gigi", will: 1 }
			@sr.away_score = nonsense
			@sr.away_score.should eq(nonsense)
		end
		it 'assigns nil if I give it nil' do
			@sr.away_score = nil
			@sr.away_score.should be_nil
		end
		it 'turns string numbers to ints if I give it ints' do
			string_score = { first_half: '1' , second_half: '3', full_time: '4' }
			int_score = { first_half: 1 , second_half: 3, full_time: 4 }

			@sr.away_score = string_score	
			@sr.away_score.should eq(int_score)
		end
		it 'assings ints if I give it ints' do
			int_score = { first_half: 1 , second_half: 3, full_time: 4 }

			@sr.away_score = int_score	
			@sr.away_score.should eq(int_score)
		end
	end
	
	describe '#draw?' do
		before :each do
			@home_team = FactoryGirl.build :team
			@away_team = FactoryGirl.build :team
			away_score = { first_half: 1, second_half: 0, full_time: 1 }
			home_score = { first_half: 0, second_half: 2, full_time: 2 }
			@result = FactoryGirl.build :soccer_result, home_score: home_score, away_score: away_score
			@result.stub(home_team: @home_team)
			@result.stub(away_team: @away_team)
		end
		it 'returns true if it was a draw' do
			@result.away_score = { first_half: 0, second_half: 0, full_time: 0 }
			@result.home_score = { first_half: 0, second_half: 0, full_time: 0 }

			@result.draw?.should be_true
		end
		it 'returns false if it was not a draw' do
			@result.draw?.should be_false
		end
	end

	describe '#home_final_score_str' do
		it 'returns the home score' do
			away_score = { first_half: 1, second_half: 0, full_time: 1 }
			home_score = { first_half: 0, second_half: 2, full_time: 2 }
			@result = FactoryGirl.build :soccer_result, home_score: home_score, away_score: away_score

			@result.home_final_score_str.should eq(2)
		end
	end

	describe '#away_final_score_str' do
		it 'returns the away score' do
			away_score = { first_half: 1, second_half: 0, full_time: 1 }
			home_score = { first_half: 0, second_half: 2, full_time: 2 }
			@result = FactoryGirl.build :soccer_result, home_score: home_score, away_score: away_score

			@result.away_final_score_str.should eq(1)
		end
	end

	describe '#won?' do
		before :each do
			@home_team = FactoryGirl.build :team
			@away_team = FactoryGirl.build :team
			away_score = { first_half: 1, second_half: 0, full_time: 1 }
			home_score = { first_half: 0, second_half: 2, full_time: 2 }
			@result = FactoryGirl.build :soccer_result, home_score: home_score, away_score: away_score
			@result.stub(home_team: @home_team)
			@result.stub(away_team: @away_team)
		end
		it 'returns true if the team won' do
			@result.won?(@home_team).should be_true
		end
		it 'returns false if the team lost' do
			@result.won?(@away_team).should be_false
		end
	end

	describe '#lost?' do
		before :each do
			@home_team = FactoryGirl.build :team
			@away_team = FactoryGirl.build :team
			away_score = { first_half: 1, second_half: 0, full_time: 1 }
			home_score = { first_half: 0, second_half: 2, full_time: 2 }
			@result = FactoryGirl.build :soccer_result, home_score: home_score, away_score: away_score
			@result.stub(home_team: @home_team)
			@result.stub(away_team: @away_team)
		end
		it 'returns true if the teams lost' do
			@result.lost?(@away_team).should be_true
		end
		it 'returns false if the team won' do
			@result.lost?(@home_team).should be_false
		end
	end
end