class CreateNotificationItems < ActiveRecord::Migration
  def change
    create_table :notification_items do |t|
      t.string :subj_type
      t.integer :subj_id
      t.string :verb
      t.string :obj_type
      t.integer :obj_id
      t.timestamp :processed_at

      t.timestamps
    end
  end
end
