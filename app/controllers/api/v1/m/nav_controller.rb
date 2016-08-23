# This is a special controller for the mobile nav. As the menu is full of
#   items only related in that they are to do with the current user, 
#   populating it requires lots of requests over mobile bandwidth.
#   This class alleviates that problem, but I'm very keen little else
#   gets put in here... It should not become a general solution for 
#   reducing requests. TS
class Api::V1::M::NavController < Api::V1::ApplicationController
	skip_authorization_check only: [:show] # It's only their stuff...

	# **** This has now got way out of hand; switch to rabl files. TS ****
	def show
		# get the app, that we stuck in the params, from the header
		app = MobileApp.find(params[:app_instance_id])
		# create a landlord, so we can tenant all the data
		land_lord = LandLord.new(app)

		# to avoid writing rabl files specifically this purpose, I'm just going
		#   to build the json here... (It's not going to change much, and there's
		#   no possibility of reuse). TS
		@nav_data = { teams: [], leagues: [], user: {} }

		#Add current user
		@nav_data[:user] = {
			id: current_user.id,
			profile_picture_thumb_url: current_user.profile.profile_picture_thumb_url,
			profile_picture_small_url: current_user.profile.profile_picture_small_url,
			profile_picture_medium_url: current_user.profile.profile_picture_medium_url,
			team_roles: [],
			stated_faft_team_role: current_user.stated_faft_team_role
		}

		#Add current users team roles
		current_user.team_roles.each do |team_role|
			next unless land_lord.is_same_tenant_as? team_role.obj

			@nav_data[:user][:team_roles] << { 
				id: team_role.id, 
				role_id: team_role.role_id, 
				user_id: team_role.user_id, 
				team_id: team_role.obj_id 
			}
		end
		
		@teams = land_lord.teams(current_user)
		@leagues = land_lord.leagues_through_teams(current_user)

		@teams.each do |t|
			team_data = {
				id: t.id,
				name: t.name,
				colour1: t.profile.colour1,
				colour2: t.profile.colour2,
				profile_picture_thumb_url: t.profile.profile_picture_thumb_url,
				profile_picture_small_url: t.profile.profile_picture_small_url,
				profile_picture_medium_url: t.profile.profile_picture_medium_url,
				permissions: {
					can_read_private_details: can?(:read_private_details, t),
					can_manage: can?(:manage, t),
					can_add_followers: can?(:add_follower, t),
					can_update_notification_settings: can?(:update_notification_settings, t)
				},
				settings: {
					team_followable: t.config.team_followable == true,
					show_app_check_in: t.config.show_app_check_in == true,
					event_compulsory_fields: t.config.event_compulsory_fields || [],
					event_extra_fields: t.config.event_extra_fields || []
				},
				has_organiser: t.organisers.count > 0,
				show_availability: !t.alien_team?,
				tenant_id: t.tenant_id,
				league: false
			}

			# Added an extra check !t.primary_division.league.nil? because in some cases it is nil.
			# It also looks like we do not return NullLeague from a DivisionSeason - PR
			if !t.primary_division.is_a?(NullDivision) && !t.primary_division.league.is_a?(NullLeague) && !t.primary_division.league.nil?
				team_data[:league] = {
					id: t.primary_division.league.id
				}
			end

			@nav_data[:teams] << team_data
		end

		@leagues.each do |l|
			league_data = {
				id: l.id,
				title: l.title,
				colour1: l.colour1,
				colour2: l.colour2,
				cover_image_url: l.cover_image_url,
				logo_thumb_url: l.logo_thumb_url,
				logo_small_url: l.logo_small_url,
				logo_medium_url: l.logo_medium_url,
				divisions: []
			}

			# filter out divisions they don't have a team in
			divs_to_display = @teams.map{ |t| t.divisions }.flatten.compact.uniq

			l.divisions.each do |d|
				next unless divs_to_display.include? d

				div_data = {
					id: d.id,
					title: d.title,
					scoring_system: d.scoring_system,
					show_standings: d.show_standings
				}
				league_data[:divisions] << div_data
			end

			@nav_data[:leagues] << league_data
		end

		render status: :ok, json: @nav_data
	end
end