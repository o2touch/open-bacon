class CreateEventRemindersQueueItems < ActiveRecord::Migration
  def change
    create_table :event_reminders_queue_items do |t|
      t.integer :event_id
      t.date :scheduled_time
      t.string :token

      t.timestamps
    end
  end
end
