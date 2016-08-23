class CreateUnclaimedLeagueProfiles < ActiveRecord::Migration
  def change
    create_table :unclaimed_league_profiles do |t|
      t.string :name
      t.string :sport

      t.timestamps
    end
  end
end
