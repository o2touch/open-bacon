class ChangeColumnNameColToColour < ActiveRecord::Migration
  def change
  	rename_column :team_profiles, :col1, :colour1
  	rename_column :team_profiles, :col2, :colour2
  	rename_column :unclaimed_team_profiles, :col1, :colour1
  	rename_column :unclaimed_team_profiles, :col2, :colour2
  end
end
