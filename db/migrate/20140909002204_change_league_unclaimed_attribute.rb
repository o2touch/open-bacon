class ChangeLeagueUnclaimedAttribute < ActiveRecord::Migration
  def change
    add_column :leagues, :claimed, :boolean, :default => false
    add_column :leagues, :claimed_date, :timestamp
    remove_column :leagues, :unclaimed
  end
end
