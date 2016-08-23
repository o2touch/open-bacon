class AddLocationToLeague < ActiveRecord::Migration
  def change
  	add_column :leagues, :location_id, :integer
  end
end
