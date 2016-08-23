class CreateTeamsheetEntries < ActiveRecord::Migration
  def change
    create_table :teamsheet_entries do |t|
      t.timestamps
    end
  end
end
