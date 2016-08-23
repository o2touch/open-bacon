require 'spec_helper'

describe FootballResult do
	describe 'validations' do
		before :each do
			home_score = { first_quarter: '3', second_quarter: '3', third_quarter: '3', fourth_quarter: '0', over_time: '14', final: '22' }
			away_score = { first_quarter: '2', second_quarter: '8', third_quarter: '7', fourth_quarter: '5', over_time: '0', final: '23' }
			@result = FactoryGirl.build :football_result, home_score: home_score, away_score: away_score
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
			@result.home_score[:first_quarter] = nil
			@result.should_not be_valid
			@result.away_score[:first_quarter] = nil
			@result.should be_valid
		end
		it 'must have neither or both second half scores set' do
			@result.home_score[:second_quarter] = nil
			@result.should_not be_valid
			@result.away_score[:second_quarter] = nil
			@result.should be_valid
		end
		it 'must have both full time scores set' do
			@result.home_score[:final] = nil
			@result.should_not be_valid
			@result.away_score[:final] = nil
			@result.should_not be_valid
		end
		it 'must have all scores must be integers' do
			@result.home_score[:first_quarter] = "cat"
			@result.should_not be_valid
			@result.home_score[:first_quarter] = 1.5
			@result.should_not be_valid
		end
		it 'must have all scores greater or equal to zero' do
			@result.home_score[:first_quarter] = -1
			@result.should_not be_valid
		end
		it 'must not have invalid score types' do
			@result.home_score[:second_half] = 1
			@result.should_not be_valid
		end
	end

	describe '#winning_team' do
		it 'returns the winning_team if there was a winner' do
			@away_team = FactoryGirl.build :team
			home_score = { first_quarter: '3', second_quarter: '3', third_quarter: '3', fourth_quarter: '0', over_time: '14', final: '22' }
			away_score = { first_quarter: '2', second_quarter: '8', third_quarter: '7', fourth_quarter: '5', over_time: '0', final: '23' }
			@result = FactoryGirl.build :football_result, home_score: home_score, away_score: away_score
			@result.stub(home_team: @home_team)

			@result.winning_team.should eq(@home_team)
		end
		it 'return nil if it was a draw' do
			home_score = { first_quarter: '3', second_quarter: '3', third_quarter: '3', fourth_quarter: '0', over_time: '14', final: '22' }
			away_score = { first_quarter: '2', second_quarter: '8', third_quarter: '7', fourth_quarter: '5', over_time: '0', final: '23' }
			@result = FactoryGirl.build :football_result, home_score: home_score, away_score: away_score

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
			string_score = { first_quarter: '1' , second_quarter: '3', final: '4' }
			int_score = { first_quarter: 1 , second_quarter: 3, final: 4 }

			@sr.home_score = string_score	
			@sr.home_score.should eq(int_score)
		end
		it 'assings ints if I give it ints' do
			int_score = { first_quarter: 1 , second_quarter: 3, final: 4 }

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
			string_score = { first_quarter: '1' , second_quarter: '3', final: '4' }
			int_score = { first_quarter: 1 , second_quarter: 3, final: 4 }

			@sr.away_score = string_score	
			@sr.away_score.should eq(int_score)
		end
		it 'assings ints if I give it ints' do
			int_score = { first_quarter: 1 , second_quarter: 3, final: 4 }

			@sr.away_score = int_score	
			@sr.away_score.should eq(int_score)
		end
	end
	
	describe '#draw?' do
		before :each do
			@home_team = FactoryGirl.build :team
			@away_team = FactoryGirl.build :team
			away_score = { first_quarter: 1, second_quarter: 0, final: 1 }
			home_score = { first_quarter: 0, second_quarter: 2, final: 2 }
			@result = FactoryGirl.build :football_result, home_score: home_score, away_score: away_score
			@result.stub(home_team: @home_team)
			@result.stub(away_team: @away_team)
		end
		it 'returns true if it was a draw' do
			@result.away_score = { first_quarter: 0, second_quarter: 0, final: 0 }
			@result.home_score = { first_quarter: 0, second_quarter: 0, final: 0 }

			@result.draw?.should be_true
		end
		it 'returns false if it was not a draw' do
			@result.draw?.should be_false
		end
	end

	describe '#home_final_score_str' do
		it 'returns the home score' do
			away_score = { first_quarter: 1, second_quarter: 0, final: 1 }
			home_score = { first_quarter: 0, second_quarter: 2, final: 2 }
			@result = FactoryGirl.build :football_result, home_score: home_score, away_score: away_score

			@result.home_final_score_str.should eq(2)
		end
	end

	describe '#away_final_score_str' do
		it 'returns the away score' do
			away_score = { first_quarter: 1, second_quarter: 0, final: 1 }
			home_score = { first_quarter: 0, second_quarter: 2, final: 2 }
			@result = FactoryGirl.build :football_result, home_score: home_score, away_score: away_score

			@result.away_final_score_str.should eq(1)
		end
	end

	describe '#won?' do
		before :each do
			@home_team = FactoryGirl.build :team
			@away_team = FactoryGirl.build :team
			away_score = { first_quarter: 1, second_quarter: 0, final: 1 }
			home_score = { first_quarter: 0, second_quarter: 2, final: 2 }
			@result = FactoryGirl.build :football_result, home_score: home_score, away_score: away_score
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
			away_score = { first_quarter: 1, second_quarter: 0, final: 1 }
			home_score = { first_quarter: 0, second_quarter: 2, final: 2 }
			@result = FactoryGirl.build :football_result, home_score: home_score, away_score: away_score
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