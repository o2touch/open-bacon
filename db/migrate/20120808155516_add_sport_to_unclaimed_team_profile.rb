class AddSportToUnclaimedTeamProfile < ActiveRecord::Migration
  def change
    add_column :unclaimed_team_profiles, :sport, :string
  end
end
