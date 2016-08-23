module EventSearch

	def self.included(klazz)
		klazz.class_eval do
			include AlgoliaSearch

			# TODO: convert to using indices per tenant
			algoliasearch index_name: "o2_touch_events", per_environment: true, if: :is_o2_touch_event? do
				customRanking ["asc(time)"]
				geoloc :lat, :lng

				tags do
					[(!team.nil? && team.settings[:touchbase_team] == true) ? "touchbase" : nil].compact
				end

				attributes :id, :title, :game_type_string
				attribute(:club_name){ team.nil? || team.club.nil? ? "" : team.club.name }
				attribute(:time){ time.to_i }
				attribute(:time_local){ time_local }

				attribute(:address_title){ location.nil? ? "" : location.title }
				attribute(:address){ location.nil? ? "" : location.address }

				attribute(:price){ tenanted_attrs[:price] }
			end
		end
	end

	# THIS IS GASH, ting should clearly accept a block!
	def lat
		location.nil? ? nil : location.lat
	end

	def lng
		location.nil? ? nil : location.lng
	end
end