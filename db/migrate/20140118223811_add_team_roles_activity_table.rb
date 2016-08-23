class AddTeamRolesActivityTable < ActiveRecord::Migration
  def up
    create_table :team_roles_activity do |t|
      t.integer :user_id
      t.integer :team_id
      t.integer :role_id
      t.datetime :created_at
	  t.datetime :removed_at
    end

    TeamRolesActivity.reset_column_information
    
    TeamRole.find_each do |tr|
    	TeamRolesActivity.create(
    		:user_id => tr.user_id,
    		:team_id => tr.team_id,
    		:role_id => tr.role_id,
    		:created_at => tr.created_at
    	)
    end

  end
  def down
  	drop_table :team_roles_activity
  end
end