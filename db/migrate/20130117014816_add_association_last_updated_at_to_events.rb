class AddAssociationLastUpdatedAtToEvents < ActiveRecord::Migration 
	def change
	  	add_column :events, :teamsheet_entries_last_updated_at, :timestamp
	end
end
