class DivisionCard < HomeCard

	attr_accessor :team

	def initialize(division)
		self.obj = division
		self.obj_type = :division
	end

	def to_json

		raise Exception.new if obj.nil?
		raise Exception.new if team.nil?

		as_json = super

		league = obj.league
		league_id = league.nil? ? nil : league.id

		as_json[:obj] = {
			:id => obj.id,
			:league => {
				id: league_id
			}
		}

		as_json[:data] = {
			:team => {},
			:fixtures => []
		}

		as_json[:data][:team] = {
			:id => team.id
		}

		# Past Fixtures
		fixtures = []
		obj.past_fixtures.first(5).each do |fixture|

			result = {}
			unless fixture.result.nil?
				result = {
					:home_final_score_str => fixture.result.home_score[:full_time],
					:away_final_score_str => fixture.result.away_score[:full_time],
					:home_team_won => fixture.result.home_team_won?,
					:away_team_won => fixture.result.away_team_won?
				}
			end

			fixture_json = {
				:id => fixture.id,
				:status => fixture.status,
				:home_team => { },
				:away_team => { },
				:result => result
			} 

			unless fixture.home_team.nil?
				fixture_json[:home_team] = {
					:id => fixture.home_team.id,
					:name => fixture.home_team.name,
					:colour1 => fixture.home_team.profile.colour1,
					:profile_picture_thumb_url => fixture.home_team.profile.profile_picture_thumb_url,
					:profile_picture_small_url => fixture.home_team.profile.profile_picture_small_url,
					:profile_picture_medium_url => fixture.home_team.profile.profile_picture_medium_url
				}
			end

			unless fixture.away_team.nil?
				fixture_json[:away_team] = {
					:id => fixture.away_team.id,
					:name => fixture.away_team.name,
					:colour1 => fixture.away_team.profile.colour1,
					:profile_picture_thumb_url => fixture.away_team.profile.profile_picture_thumb_url,
					:profile_picture_small_url => fixture.away_team.profile.profile_picture_small_url,
					:profile_picture_medium_url => fixture.away_team.profile.profile_picture_medium_url
				}
			end

			fixtures << fixture_json
		end

		as_json[:data][:fixtures] = fixtures

		return as_json
	end
end