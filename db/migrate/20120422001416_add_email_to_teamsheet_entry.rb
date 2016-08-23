class AddEmailToTeamsheetEntry < ActiveRecord::Migration
  def change
    add_column :teamsheet_entries, :email, :string
  end
end
