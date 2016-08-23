class AddColumnsToUnclaimedTeamProfiles < ActiveRecord::Migration
  def change
    add_column :unclaimed_team_profiles, :contact_name2, :string
    add_column :unclaimed_team_profiles, :contact_number2, :string
    add_column :unclaimed_team_profiles, :contact_email2, :string
    add_column :unclaimed_team_profiles, :contact_title2, :string
    add_column :unclaimed_team_profiles, :contact_title, :string
  end
end
