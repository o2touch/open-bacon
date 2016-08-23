class Api::V1::TeamDivisionSeasonRolesController < Api::V1::ApplicationController
	skip_authorization_check only: [:create]
	# everywhere we just call the TeamDSService, and check some perms
	# TODO: update when xxx_roles is done

	def create
		# league admin can add
		# anyone can add (own team) as pending iff league is addable
		ds = DivisionSeason.find params[:division_season_id]
		team = Team.find team[:team_id]

		if can? :manage_teams, ds
			TeamDSService.add_team(ds, team)
		else
			authorize! :add_team, ds
			TeamDSService.add_pending_team(ds, team)
		end

		respond_with tdsr
	end

	def update
		team = Team.find params[:team_id]
		ds = DivisionSeason.find params[:division_season_id]
		role = params[:role]

		raise InvalidParameter.new("approve or reject required") if role != "approve" && role != "reject"

		authorize! :manage_teams, ds
		TeamDSService.approve_team(ds, team) if role == "approve"
		TeamDSService.reject_team(ds, team) if role == "reject"

		head :no_content
	end

	def destroy
		team = Team.find params[:team_id]
		ds = DivisionSeason.find params[:division_season_id]

		authorize! :manage_teams, ds

		TeamDSService.remove_teame(ds, team)

		head :no_content
	end
end