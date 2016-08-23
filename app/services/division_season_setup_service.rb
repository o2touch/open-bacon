########
#
# Code to setup all the division seasons/fixed divisions.
#
# Create in a service for ease/speed of running in testing.
# To be delete once division seasons are setup, with the alien processor processing
#  division seasons/fixed divisions successfully.
#
#######
class DivisionSeasonSetupService

	def self.create_fixed_divisions
		# setup team division season roles (enough to work, no alien shit yet...)
		query = "update team_division_season_roles set role=#{TeamDSRoleEnum::MEMBER}, created_at=NOW(), updated_at=NOW()"
		ActiveRecord::Base.connection.execute(query)

		# update bf_object_type col in DSL; Division -> DivisionSeason
		query = "update data_source_links set bf_object_id='DivisionSeason' where bf_object_id='Division'"
		ActiveRecord::Base.connection.execute(query)

		DivisionSeason.find_each do |ds|
			# don't create one if it already exists...
			next unless ds.fixed_division.nil?

			# create FD, link with league/DS, set rank
			fd = FixedDivision.create!({
				league_id: ds.league_id,
				current_division_season_id: ds.id,
				rank: ds.rank,
				tenant_id: ds.tenant_id
			})

			# remove league_id, rank from DS
			ds.league_id = nil
			ds.rank = nil
			ds.fixed_division_id = fd.id
			ds.save!

			print "."
		end
		puts "done"

		# TODO: remove rank/league_id cols from division_season
		# TODO: add source/source_id (ie. setup alien shit)
	end

	def self.create_poly_roles
		query = "update poly_roles set obj_type='Team'"
		ActiveRecord::Base.connection.execute(query)

		LeagueRole.find_each do |lr|
			# don't import any old roles, innit.
			lr.destroy and next if lr.user.nil?
			lr.destroy and next if lr.league.nil?

			PolyRole.create({
				user: lr.user,
				obj: lr.league,
				role_id: PolyRole::ORGANISER
			})

			lr.destroy
		end
	end
end