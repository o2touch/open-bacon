######
#
# A module to make it slightly easier for a user to have roles on any model.
#
# Include this module, and call roleable to set the valid roles for the model. eg.
#
#  roleable roles: [PolyRole::PLAYER, PolyRole::WINNER, PolyRole::CHIEF_DICKHEAF]
#
# Then you can totes call eg. my_sweet_team.team_roles to get the roles, and 
#  create them in the normal way.
#
# The name of the association on the non-user side, will have the name of that class.
#  ie. Team = my_team.team_roles, League = my_league.league_roles etc.
#
# On the user side they'll all be under user.poly_roles, but I suggest you setup some
#  sweet has_many_through associations (and some cacheing), innit.
#
# TS
####
module Roleable

class RoleableError < StandardError; end
	extend ActiveSupport::Concern

	included do
		# if the including class is Team, the association will be :team_roles
		association_name = "#{self.name.underscore}_roles".to_sym
		has_many association_name, class_name: "PolyRole", as: :obj
	end

	module ClassMethods

		# set the options, right now it's just which roles are allowed. Add new roles to
		#  the PolyRoleEnum
		def roleable(options={})
			raise RoleableError.new("roleable expects :roles option") if options[:roles].nil?
			raise RoleableError.new(":roles must be array") unless options[:roles].is_a? Array
			raise RoleableError.new(":roles must not be empty") if options[:roles].empty?

			options[:roles].each do |r|
				raise RoleableError.new("#{r} is an invalid role") unless PolyRole.roles.include?(r)
			end
			@valid_roles = options[:roles]
		end

		def valid_role?(role)
			return false if @valid_roles.nil?
			@valid_roles.include? role
		end
	end
end