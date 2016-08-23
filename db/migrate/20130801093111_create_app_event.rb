class CreateAppEvent < ActiveRecord::Migration
  def change
    create_table :app_events do |t|
      t.string :subj_type
      t.integer :subj_id
      t.string :obj_type
      t.integer :obj_id
      t.string :verb
      t.text :meta_data
      t.timestamp :processed_at

      t.timestamps
    end
  end
end
