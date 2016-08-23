class AddInviteResponsesCountToTeamsheets < ActiveRecord::Migration
  def change
    add_column :teamsheet_entries, :invite_responses_count, :integer, default: 0, null: false
  end
end
