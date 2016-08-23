class AddSourceToUnclaimedTeamProfileTable < ActiveRecord::Migration
  def change
    add_column :unclaimed_team_profiles, :source, :string, :default => "UNKNOWN"
  end
end
