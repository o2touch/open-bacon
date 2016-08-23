class FixtureCard < HomeCard

	attr_accessor :team

	def initialize(fixture)
		self.obj = fixture
		self.obj_type = :fixture
	end

	def to_json

		raise Exception.new if obj.nil?
		raise Exception.new if self.type == :fixture_result && obj.result.nil?

		as_json = super

		home_team = nil
		unless obj.home_team.nil?
			home_team = {
				:id => obj.home_team_id,
				:name => obj.home_team.name,
				:colour1 => obj.home_team.profile.colour1,
				:profile_picture_thumb_url => obj.home_team.profile.profile_picture_thumb_url,
				:profile_picture_small_url => obj.home_team.profile.profile_picture_small_url,
				:profile_picture_medium_url => obj.home_team.profile.profile_picture_medium_url
			}
		end

		away_team = nil
		unless obj.away_team.nil?
			away_team = {
				:id => obj.away_team_id,
				:name => obj.away_team.name,
				:colour1 => obj.away_team.profile.colour1,
				:profile_picture_thumb_url => obj.away_team.profile.profile_picture_thumb_url,
				:profile_picture_small_url => obj.away_team.profile.profile_picture_small_url,
				:profile_picture_medium_url => obj.away_team.profile.profile_picture_medium_url
			}
		end

		result = nil
		unless obj.result.nil?
			result = {
				:home_final_score_str => obj.result.home_score[:full_time],
				:away_final_score_str => obj.result.away_score[:full_time],
				:home_team_won => obj.result.home_team_won?,
				:away_team_won => obj.result.away_team_won?
			}
		end

		as_json[:obj] = {
			:id => obj.id,
			:status => obj.status,
			:home_team => home_team,
			:away_team => away_team,
			:result => result
		}

		home_or_away_str = obj.home_team?(team) ? "home" : "away"
		event = obj.home_team?(team) ? obj.home_event : obj.away_event
		as_json[:data] = {
			:home_or_away => home_or_away_str,
			:linked_event => {
				:id => event.id,
				:team => {
					:id => event.team_id
				}
			}
		}

		return as_json
	end
end