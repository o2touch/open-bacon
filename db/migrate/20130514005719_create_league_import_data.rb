class CreateLeagueImportData < ActiveRecord::Migration
  def change
  	create_table :league_import_data do |t|
  		t.references :league
  		t.string :model_type
  		t.string :identifier
  		t.text :params
  		t.boolean :model_created
  		t.integer :model_id
  		t.integer :valid_record
  		t.string	:message
  		t.string :file
  		t.integer :line

      t.timestamps
	  end
  end
end
