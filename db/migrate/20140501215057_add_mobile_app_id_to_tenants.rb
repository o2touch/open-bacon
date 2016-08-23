class AddMobileAppIdToTenants < ActiveRecord::Migration
  def change
  	add_column :tenants, :mobile_app_id, :integer
  end
end
