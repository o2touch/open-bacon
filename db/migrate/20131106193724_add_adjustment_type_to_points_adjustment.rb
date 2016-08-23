class AddAdjustmentTypeToPointsAdjustment < ActiveRecord::Migration
  def change
  	add_column :points_adjustments, :adjustment_type, :string
  end
end
