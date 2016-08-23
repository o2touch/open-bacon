class AddLaunchedToDivisions < ActiveRecord::Migration
  def change
  	add_column :divisions, :launched, :boolean, :default => false
  	add_column :divisions, :launched_at, :timestamp
  end
end
