# This class is not generallized for use by any tenant.
#  Really we don't want this shit to be used (at least not as is).
class Tenants::CsvDownloadsController < ApplicationController


	# slow as fuck but does the job.
	# reflects the refactored ting.
	def users
    teams = Team.where(tenant_id: 2) # o2 touch, obvs
    members = teams.map(&:members)
    members.flatten!
    members.uniq!

    @csv = CSV.generate do |csv|
    	csv << %w(id email name dob gender experience registered_at, centre_id, centre_name, joined_centre)

    	members.each do |u|
    		row = []
    		row << u.id
    		row << u.email
    		row << u.name
    		row << u.profile.dob
    		row << u.profile.gender
    		row << (u.tenanted_attrs.nil? ? "" : u.tenanted_attrs[:player_history])
    		row << u.created_at

    		u.teams.select{ |t| t.tenant_id == 2 }.each do |t|
    			row << t.id
    			row << t.name
    			row << PolyRole.where(user_id: u.id, obj_id: t.id).map(&:created_at).sort.first
    		end
    		csv << row
    	end
    end

		respond_to do |format|
			format.html { render text: "this only returns csv" }
			format.csv { render text: @csv, layout: false }
		end
	end


	def players
    @tenant = LandLord.o2_touch_tenant
    authorize! :read_dashboard, @tenant

		team_count = Team.where(tenant_id: @tenant.id).count

		until_date = Date.today.at_end_of_month
		players = []
		admins = []

		total_players = RfuMetrics.cache.total_players(until_date, false)

		@csv = CSV.generate do |csv|
			cols = %w(name, email, club_name)
			csv << cols

			total_players.each do |p|
				row = []
				row << p.name
				row << p.email
				club = p.teams.select{ |t| t.tenant_id == 2 }.first
				club_name = club.nil? ? "" : club.name
				row << club_name
				csv << row
			end
		end

		respond_to do |format|
			format.html { render text: "this only returns csv" }
			format.csv { render text: @csv, layout: false }
		end
	end

	def per_team
    @tenant = LandLord.o2_touch_tenant
    authorize! :read_dashboard, @tenant

		cols = ["id", "Name", "Operator Count", "Player Count", "Removed Players Count", "Event Count", "Operator Emails"]

		@csv = CSV.generate do |csv|
			# titles
			csv << cols
			Team.where(tenant_id: 2).find_each do |t|

				row = []
				row << t.id
				row << t.name
				row << t.organisers.count
				row << (t.players.map(&:id) - t.organisers.map(&:id)).count
				row << (t.players.where('trashed_at IS NOT NULL').map(&:id) - t.organisers.where('trashed_at IS NOT NULL').map(&:id)).count
				row << t.events.count
				row << t.organisers.map(&:email).join(", ")
				puts row
				csv << row
			end
		end

		respond_to do |format|
			format.html { render text: "this only returns csv" }
			format.csv { render text: @csv, layout: false }
		end
	end

	def headline
    @tenant = LandLord.o2_touch_tenant
    authorize! :read_dashboard, @tenant

		team_count = Team.where(tenant_id: 2).count

		players = []
		admins = []

		with_events = 0
		without_events = 0
		event_count = 0

		until_date = Date.today.at_end_of_month

    # Total teams
    teams = MitooMetrics::Teams.created
    teams.tenant_id = @tenant.id
    total_teams = teams.in_period(Date.new(2014,4,1), until_date)

		# Total Users
    total_players = RfuMetrics.cache.total_players(until_date, false)

    total_players_ids = total_players.map { |p| p.id }

    imported_count = MitooMetrics::Users.invited_by_source("O2_TOUCH_IMPORT", total_players_ids).size
    joined_count = MitooMetrics::Users.invited_by_source("EVENT", total_players_ids).size
    added_count = MitooMetrics::Users.invited_by_source("TEAMPROFILE", total_players_ids).size

    teams = Team.find(total_teams.to_a)
    teams.each do |t|
			admins << t.organisers

			with_events += 1 if t.events.size > 0
			without_events += 1 if t.events.size == 0
			event_count += t.events.size
		end

		admins.flatten!
		admins.uniq!

    registered_players = total_players.select(&:is_registered?).size

		registered_admins = admins.select(&:is_registered?).size

		joined_pc		= joined_count / total_players.size.to_f * 100
		imported_pc = imported_count / total_players.size.to_f * 100
		added_pc		= added_count / total_players.size.to_f * 100

		registered_pc = registered_players / total_players.size.to_f * 100
		not_active_pc = (total_players.size - registered_players) / players.size.to_f * 100

		registered_admins_pc = registered_admins / admins.size.to_f * 100
		not_active_admins_pc = (admins.size-registered_admins) / admins.size.to_f * 100

		@csv = CSV.generate do |csv|
			csv << %w(Stat Count Percentage)
			csv << %w(Players)
			csv << ["Total", total_players.count]
			csv << []

			csv << ["Joined via Event", joined_count, '%.2f' % joined_pc]
			csv << ["Imported by Mitoo", imported_count, '%.2f' % imported_pc]
			csv << ["Added by Operator", added_count, '%.2f' % added_pc]
			csv << []

			csv << ["Account Activated", registered_players, '%.2f' % registered_pc]
			csv << ["Account Not Activated", total_players.size-registered_players, '%.2f' % not_active_pc]
			csv << []

			csv << ["Operators (users, not clubs)"]
			csv << ["Total", admins.size]
			csv << []

			csv << ["Account Activated", registered_admins, '%.2f' % registered_admins_pc]
			csv << ["Account Not Activated", admins.size-registered_admins, '%.2f' % not_active_admins_pc]
			csv << []

			csv << %w(Events)
			csv << ["Total", event_count]
			csv << []

			csv << %w(Teams)
			csv << ["Total", team_count]
			csv << []
			csv << ["With Events", with_events, '%.2f' % (with_events/team_count.to_f*100)]
			csv << ["Without Events", without_events, '%.2f' % (without_events/team_count.to_f*100)]
			csv << []
			csv << ["Average Event Count (all teams)", event_count/team_count.to_f]
			csv << ["Average Event Count (teams with events)", event_count/with_events.to_f]
		end

		respond_to do |format|
			format.html { render text: "this only returns csv " }
			format.csv { render text: @csv, layout: false }
		end
	end
end