class AddBatchToLeagueImportData < ActiveRecord::Migration
  def change
  	add_column :league_import_data, :batch, :integer
  end
end
