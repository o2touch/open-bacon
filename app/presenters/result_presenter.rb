class ResultPresenter < Draper::Decorator

	def result_as_letter_for_team(team)
		return '' if object.nil?
		return '' if team != object.home_team && team != object.away_team
		return 'D' if object.draw?
		return 'W' if object.won?(team)
		return 'L' if object.lost?(team)
		return '-'
	end

	def result_for_team(team)
		return '' if object.nil?
		return '' if team != object.home_team && team != object.away_team
		return 'Draw' if object.draw?
		return 'Won' if object.won?(team)
		return 'Lost' if object.lost?(team)
		return '-'
	end

	def final_score
		return "" if object.nil?
		object.home_final_score_str.to_s + ':' + object.away_final_score_str.to_s
	end

end