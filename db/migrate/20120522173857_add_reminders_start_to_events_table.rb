class AddRemindersStartToEventsTable < ActiveRecord::Migration
  def change
    add_column :events, :reminders_start, :date
  end
end
