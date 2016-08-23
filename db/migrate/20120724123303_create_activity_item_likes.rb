class CreateActivityItemLikes < ActiveRecord::Migration
  def change
    create_table :activity_item_likes do |t|
      t.integer :activity_item_id
      t.integer :user_id

      t.timestamps
    end
  end
end
