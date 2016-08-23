class AddLookupIndexToTeamsheetEntries < ActiveRecord::Migration
  def change
    add_index "teamsheet_entries", ["user_id"]
  end
end
