class CreateOpenGraphEvents < ActiveRecord::Migration
  def change
    create_table :open_graph_events do |t|
      t.string :fbid
      t.string :event_id

      t.timestamps
    end
  end
end
