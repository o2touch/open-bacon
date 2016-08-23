class TransactionItems < ActiveRecord::Migration
  def change
  	create_table :transaction_items do |t|
  		t.integer :id
      t.string :tag
  		t.string :source
  		t.integer :source_id
  		t.string :source_type
      t.string :action
  		t.text :payload
  		t.text :relations
  		t.text :meta_data
  		t.text :ers
  		t.integer :status
  		t.timestamp :processed_at

  		t.timestamps
  	end
  end
end
