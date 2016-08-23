class AddLockedByAndStatusFieldToNotificationItems < ActiveRecord::Migration
  def change
    add_column :notification_items, :locked_by, :string, :null => true
    add_column :notification_items, :status, :tinyint, :default => 0
  end
end
