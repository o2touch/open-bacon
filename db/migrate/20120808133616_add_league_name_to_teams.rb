class AddLeagueNameToTeams < ActiveRecord::Migration
  def change
    add_column :teams, :league_name, :string
  end
end
