class AddPhoneNumbertToTeamsheetEntries < ActiveRecord::Migration
  def change
    add_column :teamsheet_entries, :phone_number, :string
  end
end
