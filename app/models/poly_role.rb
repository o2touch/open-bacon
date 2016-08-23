class PolyRole < ActiveRecord::Base
	include Trashable

	belongs_to :user
	belongs_to :obj, polymorphic: true

	attr_accessible :role_id, :user, :obj

	validate :validate_role_for_obj

	after_save :bust_cache
	before_destroy { |x| x.bust_cache(Time.now) }

	# I think it would be cleaner to define the roles in here,
	#  but I can't think of a way to do it that I like enough,
	#  so I'm going to leave them in bf_constants, for now.
	#  However, I have added the following, so we can access them
	#  though this class. Brap. TS.
	def self.const_missing(const)
		PolyRoleEnum[const] || super
	end

	def self.roles
		PolyRoleEnum.values
	end


	# Validations - check the class can handle that role type.
	def validate_role_for_obj
		if !self.obj.class.valid_role?(self.role_id)
			errors.add(:role_id, "invalid role for #{obj.class.name}")
		end
	end


	# I really think we should change the name of our cache methods to this. TS
  def bust_cache(time=self.updated_at)
    time = time.utc

    method = "#{obj.class.name.underscore}_roles_last_updated_at="
    self.user.send(method, time) if self.user.respond_to? method
    self.obj.send(method, time) if self.obj.respond_to? method

  	true
  end
end