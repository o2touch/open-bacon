class CreateActivityItems < ActiveRecord::Migration
  def change
    create_table :activity_items do |t|
      t.string :subj_type
      t.integer :subj_id
      t.string :verb
      t.string :obj_type
      t.integer :obj_id

      t.timestamps
    end
  end
end
