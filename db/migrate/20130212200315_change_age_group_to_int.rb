class ChangeAgeGroupToInt < ActiveRecord::Migration
  def up
  	change_column :team_profiles, :age_group, :integer
  end

  def down
  	change_column :team_profiles, :age_group, :string
  end
end
