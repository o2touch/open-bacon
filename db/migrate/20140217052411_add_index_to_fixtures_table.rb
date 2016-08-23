class AddIndexToFixturesTable < ActiveRecord::Migration
  def change
  	add_index :fixtures, :division_id
  	add_index :fixtures, :home_team_id
  	add_index :fixtures, :away_team_id
  	add_index :fixtures, :result_id
  end
end