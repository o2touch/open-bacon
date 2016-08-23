class DataSourceLinks < ActiveRecord::Migration
  def change
  	create_table :data_source_links do |t|
  		t.string :source
  		t.string :source_object_type
  		t.integer :source_object_id
  		t.string :bf_object_type
  		t.integer :bf_object_id

  		t.timestamps
  	end
  end
end
