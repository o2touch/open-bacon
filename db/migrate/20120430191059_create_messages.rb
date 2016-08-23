class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.string :text
      t.integer :user_id
      t.integer :event_id

      t.timestamps
    end
  end
end
