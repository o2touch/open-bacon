class Result < ActiveRecord::Base
	include Trashable
	
	has_one :fixture
	has_one :home_team, through: :fixture
	has_one :away_team, through: :fixture

	attr_accessible :home_score, :away_score

	serialize :home_score
	serialize :away_score

	after_save :touch_via_cache
  	before_destroy { |x| x.touch_via_cache(Time.now) }

  def touch_via_cache(time=self.updated_at)
    if self.fixture && self.fixture.home_event
  	  self.fixture.home_event.updated_at = time.utc 
  	  self.fixture.home_event.touch_via_cache(time)
    end
    if self.fixture && self.fixture.away_event
  	  self.fixture.away_event.updated_at = time.utc
  	  self.fixture.away_event.touch_via_cache(time)
    end

  	return true
  end

	def won?(team)
		return false if team.nil?
		(self.home_team_won? && team == self.home_team) || (self.away_team_won? && team == self.away_team)
	end

	def lost?(team)
		return false if team.nil?
		(self.home_team_won? && team == self.away_team) || (self.away_team_won? && team == self.home_team)
	end

	def is_special?
		false
	end

	def ==(result)
		return false unless result.is_a? Result
		return false if self.home_final_score_str != result.home_final_score_str
		return false if self.away_final_score_str != result.away_final_score_str
		true
	end

	def to_string
		"#{self.home_final_score_str} - #{self.away_final_score_str}"
	end
end

class SpecialResult < Result
	validate :can_save?
	def can_save?
		errors.add(:fixture, "cannot save a SpecialResult")
	end
	def status; :special end
	def is_special?; true end
	def home_score; {} end
	def away_score; {} end
	def draw?; false end
	def home_team_won?; false end
	def away_team_won?; false end
end

class CancelledResult < SpecialResult
	def home_final_score_str; 'C' end
	def away_final_score_str; 'C' end
	def result_as_letter(team); 'C' end
end

class PostponedResult < SpecialResult
	def home_final_score_str; 'P' end
	def away_final_score_str; 'P' end
	def result_as_letter(team); 'P' end
end

class VoidResult < SpecialResult
	def home_final_score_str; 'V' end
	def away_final_score_str; 'V' end
	def result_as_letter(team); 'V' end
end

class AbandonedResult < SpecialResult
	def home_final_score_str; 'A' end
	def away_final_score_str; 'A' end
	def result_as_letter(team); 'A' end
end

