class CreateUnclaimedTeamProfiles < ActiveRecord::Migration
  def change
    create_table :unclaimed_team_profiles do |t|
      t.string :name
      t.integer :team_id
      t.string :location
      t.string :league_name
      t.string :contact_name
      t.string :contact_number
      t.string :contact_email
      t.string :slug

      t.timestamps
    end
  end
end
