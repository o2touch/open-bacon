class CreateTeamProfiles < ActiveRecord::Migration
  def change
    create_table :team_profiles do |t|
      t.string :sport
      t.string :league_name
      t.string :col1
      t.string :col2
      t.string :age_group

      t.timestamps
    end
  end
end
