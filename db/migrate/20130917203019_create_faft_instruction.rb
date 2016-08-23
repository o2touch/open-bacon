class CreateFaftInstruction < ActiveRecord::Migration
  def change
  	create_table :faft_instructions do |t|
  		t.string :object
  		t.string :verb
  		t.timestamp :processed_at
  		t.integer :status
  		t.text :meta_data
  		t.text :preconditions
  		t.string :bf_object_type
  		t.integer :bf_object_id

  		t.timestamps
  	end
  end
end
