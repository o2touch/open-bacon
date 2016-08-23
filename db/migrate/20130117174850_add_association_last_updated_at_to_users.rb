class AddAssociationLastUpdatedAtToUsers < ActiveRecord::Migration
	def change
	  	add_column :users, :team_roles_last_updated_at, :timestamp
  		add_column :users, :events_last_updated_at, :timestamp
	end
end
