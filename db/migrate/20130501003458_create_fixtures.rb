class CreateFixtures < ActiveRecord::Migration
  def change
  	create_table :fixtures do |t|
  		t.string :title
  		t.integer :status
  		t.datetime :time
      t.string :time_zone
      t.references :division
  		t.references :location
  		t.references :home_event
  		t.references :away_event
      t.references :home_team
      t.references :away_team
      t.boolean :edited
      t.text :edits

  		t.timestamps
  	end
  end
end
