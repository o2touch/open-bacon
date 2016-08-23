class AddClubToTeams < ActiveRecord::Migration
  def change
  	add_column :teams, :club_id, :integer
  	add_column :teams, :club_verified, :boolean
  end
end
