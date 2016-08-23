class AddFaftIdToClubs < ActiveRecord::Migration
  def change
  	add_column :clubs, :faft_id, :integer
  end
end
