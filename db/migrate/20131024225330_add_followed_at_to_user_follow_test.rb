class AddFollowedAtToUserFollowTest < ActiveRecord::Migration
  def change
  	add_column :user_follow_team_tests, :followed_at, :timestamp
  	add_column :user_follow_team_tests, :error, :string
  end
end
