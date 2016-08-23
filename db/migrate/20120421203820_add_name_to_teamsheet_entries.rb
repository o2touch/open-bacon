class AddNameToTeamsheetEntries < ActiveRecord::Migration
  def change
    add_column :teamsheet_entries, :name, :string
  end
end
