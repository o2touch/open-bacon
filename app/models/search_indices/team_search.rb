module TeamSearch

  def self.included(klazz)
    klazz.class_eval do

		  # Team Index
		  include AlgoliaSearch

		  # I can't figure out how to assign the code passed to a block, to a var, so to not repeat this shit. TS

		  # THIS IS WHAT IS SHOULD BE FOR ALL TEAMS
		  algoliasearch index_name: "all_teams", per_environment: true, if: :is_public?, unless: :is_old_mitoo?, unless: :is_faft? do
		  	attributesToIndex [:name, :tenant_id]
		    attribute :id, :name, :source, :tenant_id

		    attribute :profile_picture_thumb_url do
		      !profile.nil? ? profile.profile_picture_thumb_url : nil
		    end

		    attribute :profile_picture_small_url do
		      !profile.nil? ? profile.profile_picture_small_url : nil
		    end

		    attribute :division_name do
		      !divisions.empty? ? divisions.first.title : nil
		    end

		    attribute :league_name do
		      !divisions.empty? && !divisions.first.league.nil? ? self.divisions.first.league.title : nil
		    end

		    # THIS IS TO SUPPORT THE OLD MOBILE APPS ETC.
			  add_index "public_teams", per_environment: true, if: :is_public?, unless: :is_old_mitoo?, unless: :is_faft? do
			  	attributesToIndex [:name]
			  	attribute :id, :name, :source

			    attribute :profile_picture_thumb_url do
			      !profile.nil? ? profile.profile_picture_thumb_url : nil
			    end

			    attribute :profile_picture_small_url do
			      !profile.nil? ? profile.profile_picture_small_url : nil
			    end

			    attribute :division_name do
			      !divisions.empty? ? divisions.first.title : nil
			    end

			    attribute :league_name do
			      !divisions.empty? && !divisions.first.league.nil? ? self.divisions.first.league.title : nil
			    end
			  end

			  # THIS IS FOR TENANTS, innit. TS
		    if Tenant.table_exists? # for when we're trying to migrate to create it (eg. codeship)
				 	Tenant.all.each do |t|
				 		#puts "is_#{t.name}_team?".to_sym
					  add_index "#{t.name}_teams", per_environment: true, if: "is_#{t.name}_team?".to_sym, if: :is_public? do
					  	attributesToIndex [:name]
					  	attribute :id, :name, :source

					    attribute :profile_picture_thumb_url do
					      !profile.nil? ? profile.profile_picture_thumb_url : nil
					    end

					    attribute :profile_picture_small_url do
					      !profile.nil? ? profile.profile_picture_small_url : nil
					    end

					    attribute :division_name do
					      !divisions.empty? ? divisions.first.title : nil
					    end

					    attribute :league_name do
					      !divisions.empty? && !divisions.first.league.nil? ? self.divisions.first.league.title : nil
					    end
					  end
				  end
			  end
			end
    end
  end

  def is_faft?
  	source == "faft"
  end
end