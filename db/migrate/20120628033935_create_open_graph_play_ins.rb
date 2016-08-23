class CreateOpenGraphPlayIns < ActiveRecord::Migration
  def change
    create_table :open_graph_play_ins do |t|
      t.string :fbid
      t.string :teamsheet_entry_id

      t.timestamps
    end
  end
end
