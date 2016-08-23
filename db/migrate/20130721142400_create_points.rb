class CreatePoints < ActiveRecord::Migration
  def change
  	create_table :points do |t|
  		t.text :home_points
  		t.text :away_points
  		t.string :strategy
  		t.timestamps
  	end
  end
end
