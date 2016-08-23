class ChangeDivisionEditModeToInt < ActiveRecord::Migration
  def change
  	change_column :divisions, :edit_mode, :integer
  end
end
