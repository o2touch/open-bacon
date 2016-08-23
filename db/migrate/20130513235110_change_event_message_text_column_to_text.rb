class ChangeEventMessageTextColumnToText < ActiveRecord::Migration
  def up
    change_column :event_messages, 'text', :text
  end

  def down
    change_column :event_messages, 'text', :string
  end
end
