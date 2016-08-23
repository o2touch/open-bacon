##########
#
# Code create the o2 touch shizzle
# 
# Creates clubs, teams, admins, and players,
# Leaves all users as invited, and send no emails (unless someone happens to be signed up)
# Change invite_to_team=false, to true on line 51 to send shit out, innit.
#
###########
class O2TouchImport
	require 'csv'

	ADMIN_CSV = '/Users/tim/Downloads/o2_admin_data_fixed.csv'
	USER_CSV = '/Users/tim/Downloads/o2_player_data_fixed.csv'

	def self.import_admins(path=ADMIN_CSV, find_by="club", create_club=false)
		ae_meta_data = { processor: 'Ns2::Processors::O2TouchProcessor' }

		if find_by != 'team' && find_by != 'club'
			puts "Second arg must be 'team' or 'club'"
			return
		end

		CSV.foreach path, headers: true do |csv_row|
			row = csv_row.to_hash
			name = row["Name"]
			email = row["Email"]
			gender = row["Gender"]
			club_name = row["Club Link"]
			club_postcode = row["Club Postcode"]

			if find_by == "club"
				club = Club.find_by_name(club_name)
				if club.nil? && create_club
					club = create_club(club_name, club_postcode)
				elsif club.nil? && !create_club
					puts "No such club '#{club_name}', skipping..."
					next
				end

				team = club.teams.first
			# if we're adding players to some dickhead's team
			elsif find_by == "team"
				team = Team.find_by_name(club_name)
				if team.nil?
					puts "No such team '#{club_name}', skipping..."
					next
				end
			end

			user = User.find_by_email(email)
			user = create_user(name, email, gender) if user.nil?

			if !team.members.include? user
				TeamUsersService.add_organiser(team, user, false)
				AppEventService.create(team, user, "organiser_imported", ae_meta_data)
			end
			print "."
		end
		puts "done"
	end

	def self.resend_the_shitting_emails
		ae_meta_data = { processor: 'Ns2::Processors::O2TouchProcessor' }

		Team.where(tenant_id: LandLord.o2_touch_tenant).each do |t|
			t.organisers.each do |o|
				next if o.has_activated_account?
				AppEventService.create(t, o, "organiser_imported", ae_meta_data)
			end
		end
	end

	def self.import_users(path=USER_CSV)
		ae_meta_data = { processor: 'Ns2::Processors::O2TouchProcessor' }
		shit_data = []

		CSV.foreach path, headers: true do |csv_row|
			row = csv_row.to_hash

			# wrap it in a begin rescue because the data is a pile of shit
			begin
				name = row["Name"]
				email = row["Email"]
				gender = row["Gender"]
				dob = row["DOB"]
				mobile = row["Mobile Number"]
				club_name = row["Club Link"]

				user = User.find_by_email(email)
				user = create_user(name, email, is_player=true, gender, dob, mobile,) if user.nil?

				club = Club.find_by_name(club_name)

				team = club.teams.first
				if team.players.include? user
					print "-"
					next
				end

				TeamUsersService.add_player(team, user, invite_to_team=false)
				AppEventService.create(team, user, "player_imported", ae_meta_data)
				print "."
			rescue
				shit_data << row
			end
		end
		puts "done"
		puts shit_data
	end

	def self.create_team(club)
		tenant = LandLord.o2_touch_tenant

    team = Team.new({
      name: "#{club.name} O2Touch",
      created_by_type: "User"
    })
    team.create_profile!({
      age_group: 99,
      colour1:   "1A245C",
      colour2:   "900F29",
      sport:     SportsEnum::RUGBY,
      league_name: "O2Touch Touchbase"
    })
    team.club = club

    team.tenant = tenant
    team.configurable_set_parent(tenant)

    team.save!
	end

	def self.create_club(name, postcode)
		loc = nil
		loc = Location.create({ title: postcode, address: postcode }) unless postcode.blank?

		club = Club.create!({ name: name })
		club.location = loc
		club.profile = TeamProfile.create!({ 
      age_group: 99,
			sport: SportsEnum::RUGBY,
			colour1: DefaultColourEnum::FAFT_DEFAULT_1,
			colour2: DefaultColourEnum::FAFT_DEFAULT_2,
		})
		club.tenant = LandLord.default_tenant
		club.save!

		create_team(club)

		club
	end

	def self.create_user(name, email, gender, is_player=false, dob=nil, mobile=nil)
		mobile = normalize_mobile_number(mobile)

		gender = "m" if gender == "Male"
		gender = "f" if gender == "Female"

		begin
			dob = Date.strptime(dob_str, '%d/%m/%Y') unless dob.nil?
		rescue
			#gutted
		end

		user = User.create!({
			name: name,
			email: email,
			country: "GB",
			time_zone: "Europe/London",
			invited_by_source: "O2_TOUCH_IMPORT",
			mobile_number: mobile
		})
		user.profile.update_attributes({
			gender: gender,
			dob: dob
		})
		user.update_attribute(:tenanted_attrs, { player_history: "existing" }) if is_player

		tenant = LandLord.o2_touch_tenant
		user.tenant = tenant
		user.configurable_set_parent(tenant)
		user.save!

		user.add_role(RoleEnum::INVITED)

		user
	end

	def self.normalize_club_name(name)

	end

	def self.normalize_mobile_number(mobile)
		return nil if mobile.nil?
		return nil unless mobile.starts_with?("0") || mobile.starts_with?("7")

		mobile = "0#{mobile}" if mobile.starts_with? "7"
		mobile.gsub(/\s+/, "")
	end

	def self.update_teams_with_locations
		client = ActiveRecord::Base.connection

		q = "SELECT * FROM teams_missing_postcode"

		results = client.exec_query(q, :symbolize_keys => true)
    results.each do |r|

    	next if r['Postcode'].downcase=="n/a" || r['Postcode'].nil?

      t = Team.find(r['id'])
      location = Location.create(:title => r['Postcode'], :address => r['Postcode'])

      if t.club.nil?
      	
      	c = Club.create(:name => t.name)
      	c.save

      	t.club = c
      	t.save
      end

      	t.club.location = location
      	t.club.save
    end



	end
end