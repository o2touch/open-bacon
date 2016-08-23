class AddTeamProfileIdToTeams < ActiveRecord::Migration
  def change
    add_column :teams, :profile_id, :integer
  end
end
