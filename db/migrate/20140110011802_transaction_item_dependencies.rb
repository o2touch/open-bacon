class TransactionItemDependencies < ActiveRecord::Migration
  def change
  	create_table :transaction_item_dependencies do |t|
  		t.integer :id
  		t.integer :transaction_item_id
  		t.string :source
  		t.integer :dependent_id
  		t.string :dependent_type

  		t.timestamps
  	end
  end
end
