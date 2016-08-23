class RemoveLeagueNameFromTeams < ActiveRecord::Migration
  def up
    remove_column :teams, :league_name
      end

  def down
    add_column :teams, :league_name, :string
  end
end
