class CreateDivisionsTeams < ActiveRecord::Migration
  def change
  	create_table :divisions_teams do |dt|
  		dt.integer :division_id
  		dt.integer :team_id
  	end	
  end
end
