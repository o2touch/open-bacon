class AddFaftIdToModels < ActiveRecord::Migration
  def change
  	add_column :leagues, :faft_id, :integer
  	add_column :divisions, :faft_id, :integer
  	add_column :teams, :faft_id, :integer
  	add_column :fixtures, :faft_id, :integer
  end
end
