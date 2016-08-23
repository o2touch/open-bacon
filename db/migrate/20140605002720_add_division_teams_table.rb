class AddDivisionTeamsTable < ActiveRecord::Migration
  def up
  	rename_table :divisions_teams, :team_division_season_roles
  	rename_column :team_division_season_roles, :division_id, :division_season_id

  	add_column :team_division_season_roles, :role, :integer
  	add_column :team_division_season_roles, :created_at, :timestamp
  	add_column :team_division_season_roles, :updated_at, :timestamp
  end

  def down
  end
end
 