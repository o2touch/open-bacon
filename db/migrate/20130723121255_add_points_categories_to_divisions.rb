class AddPointsCategoriesToDivisions < ActiveRecord::Migration
  def change
  	add_column :divisions, :points_categories, :text
  end
end
