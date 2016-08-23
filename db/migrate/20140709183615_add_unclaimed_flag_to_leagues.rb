class AddUnclaimedFlagToLeagues < ActiveRecord::Migration
  def change
  	add_column :leagues, :unclaimed, :boolean
  end
end
