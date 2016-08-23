class AddMetaDataToEventMessages < ActiveRecord::Migration
  def change
    add_column :event_messages, :meta_data, :text, :null => true
  end
end
