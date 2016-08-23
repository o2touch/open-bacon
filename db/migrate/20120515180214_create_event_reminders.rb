class CreateEventReminders < ActiveRecord::Migration
  def change
    create_table :event_reminders do |t|
      t.integer :teamsheet_entry_id
      t.integer :user_sent_by_id

      t.timestamps
    end
  end
end
