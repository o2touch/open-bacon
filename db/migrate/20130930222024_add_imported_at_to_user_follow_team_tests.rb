class AddImportedAtToUserFollowTeamTests < ActiveRecord::Migration
  def change
  	add_column :user_follow_team_tests, :imported_at, :timestamp
  end
end
