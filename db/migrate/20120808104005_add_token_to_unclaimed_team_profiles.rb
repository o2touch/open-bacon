class AddTokenToUnclaimedTeamProfiles < ActiveRecord::Migration
  def change
    add_column :unclaimed_team_profiles, :token, :string
  end
end
