class CreateResult < ActiveRecord::Migration
  def change
  	create_table :results do |t|
  		t.text :home_score
  		t.text :away_score
  		t.string :type

  		t.timestamps
  	end
  end
end
