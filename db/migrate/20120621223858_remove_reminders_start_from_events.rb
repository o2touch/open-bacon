class RemoveRemindersStartFromEvents < ActiveRecord::Migration
  def change
    remove_column :events, :reminders_start
  end
end
