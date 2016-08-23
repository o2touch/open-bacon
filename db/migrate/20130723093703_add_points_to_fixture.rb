class AddPointsToFixture < ActiveRecord::Migration
  def change
  	add_column :fixtures, :points_id, :integer
  end
end
