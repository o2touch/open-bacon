class UpdateDivColNameOnPas < ActiveRecord::Migration
  def change
  	rename_column :points_adjustments, :division_id, :division_season_id
  end
end
