class AddUserIdToTeamsheetEntries < ActiveRecord::Migration
  def change
    add_column :teamsheet_entries, :user_id, :integer
    remove_column :teamsheet_entries, :name
    remove_column :teamsheet_entries, :email
  end
end
