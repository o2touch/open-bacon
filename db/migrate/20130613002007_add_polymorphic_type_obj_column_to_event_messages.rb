class AddPolymorphicTypeObjColumnToEventMessages < ActiveRecord::Migration
  def up
    rename_column :event_messages, :event_id, :messageable_id
    add_column :event_messages, :messageable_type, :string
  end

  def down
    rename_column :event_messages, :messageable_id, :event_id
    remove_column :event_messages, :messageable_type
  end
end
