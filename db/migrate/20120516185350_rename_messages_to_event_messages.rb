class RenameMessagesToEventMessages < ActiveRecord::Migration
  def self.up
    rename_table :messages, :event_messages
  end

 def self.down
    rename_table :event_messages, :messages
 end
end