class AddStatusToNs2NotificationItem < ActiveRecord::Migration
  def change
  	add_column :ns2_notification_items, :status, :integer
  end
end
