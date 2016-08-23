class AddNotificationsColumnsToTenant < ActiveRecord::Migration
  def change
  	# this is kind of just place holder shit, until we actually switch to new urban airship api gem (drigible)
  	add_column :tenants, :sms, :boolean
  	add_column :tenants, :email, :boolean
  	add_column :tenants, :mobile_app, :string
  end
end
