class CreateActivityItemLinksTable < ActiveRecord::Migration
  def change
    create_table :activity_item_links do |t|
      t.integer :activity_item_id
      t.integer :feed_owner_id
      t.string :feed_owner_type
      
      t.timestamps
    end
  end
end
