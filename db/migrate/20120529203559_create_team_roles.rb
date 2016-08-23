class CreateTeamRoles < ActiveRecord::Migration
  def change
    create_table :team_roles do |t|
      t.integer :user_id
      t.integer :team_id
      t.integer :role_id

      t.timestamps
    end
  end
end
