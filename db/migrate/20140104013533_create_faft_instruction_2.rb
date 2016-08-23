class CreateFaftInstruction2 < ActiveRecord::Migration
  def up
  	create_table :faft_instructions_2 do |t|
      t.integer :transaction_item_id
  		t.timestamp :processed_at
  		t.integer :status
  		t.text :meta_data
  		t.text :payload
  		t.text :ers
  		t.string :bf_object_type
  		t.integer :bf_object_id
  		t.string :source
  		t.integer :source_id
      t.string :source_type
      t.integer :attempts
      t.string :type

  		t.timestamps
  	end
  end
end
