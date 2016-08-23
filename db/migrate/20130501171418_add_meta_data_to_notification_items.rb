class AddMetaDataToNotificationItems < ActiveRecord::Migration
  def change
    add_column :notification_items, :meta_data, :text, :null => true
  end
end
