class RemoveUnusedColumnsFromNotificationItem < ActiveRecord::Migration
  def up
    remove_column :notification_items, :locked_at if column_exists? :notification_items, :locked_at
    remove_column :notification_items, :locked_by if column_exists? :notification_items, :locked_by
    remove_column :notification_items, :status if column_exists? :notification_items, :status
  end

  def down
  end
end
