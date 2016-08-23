class AddCheckFieldsToTse < ActiveRecord::Migration
  def change
  	add_column :teamsheet_entries, :checked_in, :boolean, default: false
  	add_column :teamsheet_entries, :checked_in_at, :timestamp
  end
end
