module LeagueSearch

	def self.included(klazz)
		klazz.class_eval do
			include AlgoliaSearch

		  # Index for all leagues
		  # TODO: Only index public leagues - PR
		  algoliasearch index_name: "public_leagues", per_environment: true, unless: :is_faft? do
		  	attributesToIndex [:title, :tenant_id]
		  	geoloc :lat, :lng
		  	# is it a league that we've grabed the data for
		  	tags { [claimed? ? 'claimed' : 'unclaimed'] }

		    attribute :id, :title, :sport, :colour1, :colour2, :source, :logo_thumb_url, :logo_large_url, :tenant_id
		    attribute(:division_count){ fixed_divisions.count }

		    attribute(:address){ location.nil? ? "" : location.address }

		    attribute :league_url do
		      Rails.application.routes.url_helpers.league_url(self)
		    end
		  end
		end
	end

	def lat
		location.nil? ? nil : location.lat
	end

	def lng
		location.nil? ? nil : location.lng
	end

	def is_faft?
		source == "faft"
	end
end