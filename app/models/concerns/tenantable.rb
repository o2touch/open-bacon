module Tenantable
	extend ActiveSupport::Concern

	included do
		belongs_to :tenant

		# add methods like is_TENANT-NAME_MODEL-NAME? to tenated models (eg is_o2_touch_team?)
		define_method "is_mitoo_#{self.name.underscore}?" do
			self.tenant_id.nil? || self.tenant_id == TenantEnum::MITOO_ID
		end

 		TenantNameEnum.each do |k, v|
 			next if k == :MITOO
			define_method "is_#{v}_#{self.name.underscore}?" do
				self.tenant_id == TenantEnum.[](k)
			end
		end
	end

	module ClassMethods
	end

	# Get the domain for a tenantable object
	def get_tenant_domain
	  tenant = LandLord.new(self).tenant
	  tenant.get_domain
	end
end