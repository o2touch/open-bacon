class AddPerspectiveToEventMessage < ActiveRecord::Migration
  def up
    add_column :event_messages, :sent_as_role_type, :string
    add_column :event_messages, :sent_as_role_id, :integer
  end

  def down
    remove_column :event_messages, :sent_as_role_type
    remove_column :event_messages, :sent_as_role_id
  end
end
