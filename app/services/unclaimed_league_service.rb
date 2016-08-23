# parse scraped league data csvs from kathleen. Can be deleted when that shit is done.
class UnclaimedLeagueService
	require 'csv'

	# process a csv of league data.
	def self.import_csv(file='/Users/tim/Downloads/league_data.csv', logo_dir='/Users/tim/Dropbox/kathleen_club_images/League Logo')
		current_id = -1
		league = nil

		CSV.foreach file, headers: true do |csv_row|
			ActiveRecord::Base.transaction do
				row = csv_row.to_hash

				# make the titles nice...
				row.keys.each{ |k| row[k.gsub(/\s/, "_").downcase.to_sym] = row[k]; row.delete(k) }

				# when running the importer over the same file more than once, don't create dups
				next if current_id == -1 && League.exists?(source: "kathleen", source_id: row[:id].to_i) 

				# we've found a new league
				if current_id != row[:id].to_i
					current_id = row[:id].to_i

					# don't import the same league twice
					next if League.exists? source: "kathleen", source_id: current_id

					colour1, colour2 = normalize_colours(row[:league_colours])


					begin 
						league = League.create!({
							unclaimed: true,
							title: row[:league_name],
							sport: normalize_sport(row[:sport]),
							colour1: colour1,
							colour2: colour2,
							source: "kathleen",
							source_id: current_id
						})
					rescue
						# if validation fails... will be:
						#  - slug taken: fucked numbering in the csv
						#  - source_id taken :fucked numbering in the csv
						#
						# best off without that shit.
						next
					end

					league.settings = { girls_age_groups: [], boys_age_groups: [], adult_division_count: [] } # so we can fill it with shit.
					league.tenant = LandLord.alien_tenant

					league.location = mash_address(row)

					logo = get_logo(current_id, logo_dir)
					league.logo = logo unless logo.nil?

					league.save!
				end

				league.settings[:girls_age_groups] << row[:girls_age_groups] unless row[:girls_age_groups].nil?
				league.settings[:boys_age_groups] << row[:boys_age_groups] unless row[:boys_age_groups].nil?
				# The data we're getting for this one seems to be sometimes counts, and sometimes ages.
				# Prob best to treat as a boolean.
				league.settings[:adult_division_count] << row[:adult_division_count] unless row[:adult_division_count].nil?
				league.settings[:team_register] = true unless row[:team_register].blank?
				league.settings[:individual_register] = true unless row[:individual_register].blank?
				league.save!


				# create a contact
				if !row[:name].nil? || !row[:position].nil? || !row[:phone].nil? || !row[:email].nil? || !row[:contact_link].nil?
					contact = ScrapedContact.create!({
						name: row[:contact_name],
						position: row[:position],
						phone: row[:phone_number],
						email: row[:email_address],
						contact_link: row[:contact_link],
						org: league
					})
				end
			end
		end
	end

	#private

	def self.get_logo(id, logo_dir)
		id = id.to_s.rjust(4, "0")
		path = Dir["#{logo_dir}/#{id}.*"].first
		# filter gifs. TODO: convert to an allowed format.
		return nil if path.nil? || path.downcase.ends_with?("gif")
		puts path
		File.new(path)
	end

	def self.normalize_colours(colours)
		return nil, nil if colours.blank?

		# translate to colours that we actually want to be using
		cm = {}
		cm["436EEE"] = "4fade3"
		cm["a52a2a"] = "8a061b"
	  cm["1A245C"] = "1840a5"
    cm["008000"] = "009245"
    cm["008000"] = "009245"
    cm["003366"] = "1840a5"
    cm["003355"] = "1840a5"
    cm["F72828"] = "cc0104"
    cm["ff1717"] = "cc0104"
    cm["ffa500"] = "f7921e"
    cm["ffd700"] = "fab800"
    cm["ee82ee"] = "662c91"
    cm["000000"] = "121212"
    cm["0000ff"] = "1840A5"
    cm["ff0000"] = "cc0104"
    cm["ffffff"] = "fefefe"
    cm["ffff00"] = "fab800"

		c_array = colours.split(",").each{|c| c.strip! }
		c1, c2 = Color::CSS[c_array[0]].html[1..-1], Color::CSS[c_array[1]].html[1..-1]

		return cm[c1], cm[c2]
	rescue => e
		return nil, nil
	end

	def self.mash_address(row)
		addr = []
		addr << row[:address] unless row[:address].blank?
		addr << row[:city] unless row[:city].blank?
		addr << row[:state] unless row[:state].blank?
		addr << row[:zip_code] unless row[:zip_code].blank?
		return nil if addr.empty?

		Location.create!({ address: addr.join(", ") })
	end

	def self.normalize_sport(sport)
		sport = sport.split(" ").each{|s| s.capitalize! }.join(" ")
		sport = "Football (American)" if sport == "Football"
		sport = "Football (Soccer)" if sport == "Soccer"
		sport
	end
end