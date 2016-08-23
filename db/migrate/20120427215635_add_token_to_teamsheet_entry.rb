class AddTokenToTeamsheetEntry < ActiveRecord::Migration
  def change
    add_column :teamsheet_entries, :token, :string
    add_index :teamsheet_entries, :token, :unique => true
  end
end
