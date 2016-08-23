class AddAssociationLastUpdatedAtToTeams < ActiveRecord::Migration
	def change
	  	add_column :teams, :events_last_updated_at, :timestamp
  		add_column :teams, :team_roles_last_updated_at, :timestamp
	end
end