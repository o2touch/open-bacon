class CreateLeagues < ActiveRecord::Migration
  def change
  	create_table :leagues do |t|
  		t.string :title
  		t.string :sport
  		t.string :region

  		t.timestamps
  	end
  end
end
