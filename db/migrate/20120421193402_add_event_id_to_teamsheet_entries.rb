class AddEventIdToTeamsheetEntries < ActiveRecord::Migration
  def change
    add_column :teamsheet_entries, :event_id, :integer
    add_index :teamsheet_entries, :event_id, :name => 'event_id_ix'
  end
end
