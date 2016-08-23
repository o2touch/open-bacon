class CreatePointsAdjustment < ActiveRecord::Migration
  def change
  	create_table :points_adjustments do |t|
  		t.integer :division_id
  		t.integer :team_id
  		t.integer :adjustment
  		t.text :desc

  		t.timestamps
  	end
  end
end
