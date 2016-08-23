class CreateActivityItemComments < ActiveRecord::Migration
  def change
    create_table :activity_item_comments do |t|
      t.integer :activity_item_id
      t.integer :user_id
      t.string :text

      t.timestamps
    end
  end
end
