class CreateEventResults < ActiveRecord::Migration
  def change
    create_table :event_results do |t|
      t.integer :score_for
      t.integer :score_against

      t.timestamps
    end
  end
end
