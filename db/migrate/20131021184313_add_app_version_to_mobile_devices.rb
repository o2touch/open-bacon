class AddAppVersionToMobileDevices < ActiveRecord::Migration
  def change
  	add_column :mobile_devices, :app_version, :string
  end
end
