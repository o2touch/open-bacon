class CreateClubs < ActiveRecord::Migration
  def change
  	create_table :clubs do |t|
  		t.string :name
  		t.integer :location_id
  		t.integer :team_profile_id
  		t.timestamps
  	end
  end
end
