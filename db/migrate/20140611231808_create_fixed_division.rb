class CreateFixedDivision < ActiveRecord::Migration
	def change
  	create_table :fixed_divisions do |t|
  		t.integer :league_id
  		t.integer :current_division_season_id
  	end
  end
end
