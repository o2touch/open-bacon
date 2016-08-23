# We should blates create a HighestScoreWinsWithPeriods class, to generalise soccer/football/rugby/etc
class SoccerResult < Result
	include StandingsHelper

	validates :home_score, :away_score, presence: true
	validate :soccer_scores

	# validate soccer scores
	def soccer_scores
		self.home_score ||= {}
		self.away_score ||= {}
		
		# make sure they set both
		if self.home_score[:first_half].blank? != self.away_score[:first_half].blank?
			self.errors.add(:scores, "Both first half scores must be set")
		end
		if self.home_score[:second_half].blank? != self.away_score[:second_half].blank?
			self.errors.add(:scores, "Both second half scores must be set")
		end
		if self.home_score[:full_time].blank? || self.away_score[:full_time].blank?
			self.errors.add(:scores, "Both full time scores must be set")
		end

		valid_keys = %w(first_half second_half full_time)
		keys = []
		keys << home_score.keys
		keys << away_score.keys
		keys.flatten!
		keys.each do |k|
			self.errors.add(:scores, "#{k} is an invalid score type") unless valid_keys.include?(k.to_s)
		end

		scores = []
		scores << home_score.values
		scores << away_score.values
		scores.flatten!
		scores.each do |s|
			self.errors.add(:scores, "Scores must be postitive integers") unless s.nil? || (s.is_a?(Integer) && s >= 0)
		end
	end

	# override assignment so we can massage scores into what they need to be
	# ie. strings become ints
	def home_score=(score)
		normalised_score = hash_values_to_ints(score)
		# if the above fails, stick in whatever we got, so that errors are correct
		self[:home_score] = score if normalised_score.nil?
		self[:home_score] = normalised_score unless normalised_score.nil?
	end

	# override assignment so we can massage scores into what they need to be
	# ie. strings become ints
	def away_score=(score)
		normalised_score = hash_values_to_ints(score)
		# if the above fails, stick in whatever we got, so that errors are correct
		self[:away_score] = score if normalised_score.nil?
		self[:away_score] = normalised_score unless normalised_score.nil?
	end

	def home_team_won?
		self.home_score[:full_time] > self.away_score[:full_time]
	end

	def away_team_won?
		self.away_score[:full_time] > self.home_score[:full_time]
	end

	def winning_team
		return self.home_team if self.home_score[:full_time] > self.away_score[:full_time]
		return self.away_team if self.away_score[:full_time] > self.home_score[:full_time]
		nil
	end

	def losing_team
		return self.home_team if self.home_score[:full_time] < self.away_score[:full_time]
		return self.away_team if self.away_score[:full_time] < self.home_score[:full_time]
		nil
	end

	def draw?
		self.home_score[:full_time] == self.away_score[:full_time]
	end

	def home_final_score_str
		self.home_score ||= {}
		self.home_score[:full_time]
	end

	def away_final_score_str
		self.away_score ||= {}
		self.away_score[:full_time]
	end

	def to_s
		"#{home_score[:full_time]} - #{away_score[:full_time]}"
	end
end

class HomeWalkoverResult < SoccerResult
	before_validation do
		self[:home_score] = {full_time: 0}
		self[:away_score] = {full_time: 0}
	end
	def soccer_scores; end #override the validation method
	def winning_team; self.home_team end
	def losing_team; self.away_team end
	def draw?; false end
	def home_team_won?; true end
	def away_team_won?; false end
	def home_final_score_str; 'H' end
	def away_final_score_str; 'W' end
end

class DrawResult < SoccerResult
	before_validation do
		self[:home_score] = {full_time: 0}
		self[:away_score] = {full_time: 0}
	end
	def soccer_scores; end #override the validation method
	def winning_team; nil end
	def losing_team; nil end
	def draw?; true end
	def home_team_won?; false end
	def away_team_won?; false end
	def home_final_score_str; 'D' end
	def away_final_score_str; 'D' end
end

class AwayWalkoverResult < SoccerResult
	before_validation do
		self[:home_score] = {full_time: 0}
		self[:away_score] = {full_time: 0}
	end
	def soccer_scores; end #override the validation method
	def winning_team; self.away_team end
	def losing_team; self.home_team end
	def draw?; false end
	def home_team_won?; false end
	def away_team_won?; true end
	def home_final_score_str; 'A' end
	def away_final_score_str; 'W' end
end