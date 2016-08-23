# Service to deal with TeamDivisionSeasonRoles
class TeamDSService
	class TeamDivisionSeasonRoleError < StandardError; end

	class << self

		def add_team(div, team)
			raise TeamDivisionSeasonRoleError.new if div.teams.include? team
			raise TeamDivisionSeasonRoleError.new if div.pending_teams.include? team

			tdsr = div.team_division_season_roles.create!({
				team: team,
				role: TeamDSRoleEnum::MEMBER
			})
			team.reload

			# returned for AP creation to add source/source_id
			tdsr
		end

		def add_pending_team(div, team)
			raise TeamDivisionSeasonRoleError.new if div.teams.include? team
			raise TeamDivisionSeasonRoleError.new if div.pending_teams.include? team

			div.team_division_season_roles.create!({
				team: team,
				role: TeamDSRoleEnum::PENDING
			})
			team.reload
		end

		def remove_team(div, team)
			raise TeamDivisionSeasonRoleError.new unless div.teams.include? team

			role = TeamDivisionSeasonRole.where(team_id: team.id, division_season_id: div.id).first
			role.update_attribute(:role, TeamDSRoleEnum::DELETED)
			team.reload
		end

		def approve_team(div, team)
			raise TeamDivisionSeasonRoleError.new if div.pending_teams.include? team

			role = TeamDivisionSeasonRole.where(team_id: team.id, division_season_id: div.id).first
			role.update_attribute(:role, TeamDSRoleEnum::MEMBER)
			team.reload
		end

		def reject_team(div, team)
			raise TeamDivisionSeasonRoleError.new if div.pending_teams.include? team

			role = TeamDivisionSeasonRole.where(team_id: team.id, division_season_id: div.id).first
			role.update_attribute(:role, TeamDSRoleEnum::REJECTED)
			team.reload
		end
	end
end