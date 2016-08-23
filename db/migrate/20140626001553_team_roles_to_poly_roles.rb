class TeamRolesToPolyRoles < ActiveRecord::Migration
  def change
  	rename_table :team_roles, :poly_roles
  	rename_column :poly_roles, :team_id, :obj_id
  	add_column :poly_roles, :obj_type, :string
  	add_column :poly_roles, :trashed_at, :timestamp
  end
end
