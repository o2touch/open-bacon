class AddTenantToNs2NotificationItem < ActiveRecord::Migration
  def change
  	add_column :ns2_notification_items, :tenant_id, :integer
  end
end
