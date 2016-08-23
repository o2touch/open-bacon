class AddInviteSentToTeamsheetEntries < ActiveRecord::Migration
  def change
    add_column :teamsheet_entries, :invite_sent, :boolean, :default => false
  end
end
