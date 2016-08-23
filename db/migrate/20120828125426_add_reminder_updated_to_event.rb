class AddReminderUpdatedToEvent < ActiveRecord::Migration
  def change
    add_column :events, :reminder_updated, :integer
  end
end
