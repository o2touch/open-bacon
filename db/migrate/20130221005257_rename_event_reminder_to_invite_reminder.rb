class RenameEventReminderToInviteReminder < ActiveRecord::Migration
  def self.up
    rename_table :event_reminders, :invite_reminders
    ActivityItem.update_all({ obj_type: "InviteReminder" }, {obj_type: "EventReminder" })
  end 
  def self.down
    rename_table :invite_reminders, :event_reminders
    ActivityItem.update_all({ obj_type: "EventReminder" }, {obj_type: "InviteReminder" })
  end
end
