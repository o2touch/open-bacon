class AddLockedAtToNotificationItems < ActiveRecord::Migration
  def change
    add_column :notification_items, :locked_at, :timestamp, :null => true
  end
end
