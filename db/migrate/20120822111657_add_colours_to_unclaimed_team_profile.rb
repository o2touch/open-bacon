class AddColoursToUnclaimedTeamProfile < ActiveRecord::Migration
  def change
    add_column :unclaimed_team_profiles, :col1, :string
    add_column :unclaimed_team_profiles, :col2, :string
  end
end
