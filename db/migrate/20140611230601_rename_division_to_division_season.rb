class RenameDivisionToDivisionSeason < ActiveRecord::Migration
  def up
  	rename_table :divisions, :division_seasons
  	add_column :division_seasons, :fixed_division_id, :integer
  end

  def down
  end
end
