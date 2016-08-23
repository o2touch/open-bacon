class AddIndexToDivisionsTeams < ActiveRecord::Migration
  def change
  	add_index :divisions, :source_id
  	add_index :divisions_teams, :division_id
  	add_index :divisions_teams, :team_id
  end
end
