class CreateLeagueRoles < ActiveRecord::Migration
  def change
    create_table :league_roles do |t|
      t.integer :user_id
      t.integer :league_id
      t.integer :role_id

      t.timestamps
    end
  end
end
