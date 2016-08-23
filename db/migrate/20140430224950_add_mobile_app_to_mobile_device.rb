class AddMobileAppToMobileDevice < ActiveRecord::Migration
  def change
  	add_column :mobile_devices, :mobile_app_id, :integer
  	remove_column :mobile_devices, :tenant_id
  end
end
