class AddSlugToUnclaimedLeagueProfile < ActiveRecord::Migration
  def change
    add_column :unclaimed_league_profiles, :slug, :string
  end
end
