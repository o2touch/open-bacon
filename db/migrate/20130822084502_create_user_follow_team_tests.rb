class CreateUserFollowTeamTests < ActiveRecord::Migration
  def change
    create_table :user_follow_team_tests do |t|
      t.integer :user_id
      t.integer :faft_division_season_id
      t.integer :faft_team_id
      t.timestamps
    end
  end
end
