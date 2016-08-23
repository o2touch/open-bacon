class AddMetadataToActivityItems < ActiveRecord::Migration
  def change
    add_column :activity_items, :meta_data, :text, :null => true
  end
end
