class CreateUnclaimedTeamProfileProblems < ActiveRecord::Migration
  def change
    create_table :unclaimed_team_profile_problems do |t|

      t.integer :unclaimed_team_profile_id
      t.string :problem_type
      t.string :additional_info

      t.timestamps
    end
  end
end
