class CreateDivisions < ActiveRecord::Migration
  def change
  	create_table :divisions do |t|
  		t.string :title
  		t.integer :rank
  		t.datetime :start_date
  		t.datetime :end_date
  		t.integer :age_group
  		t.references :league
      t.boolean :edit_mode

  		t.timestamps
  	end
  end
end
