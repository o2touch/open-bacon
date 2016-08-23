class AddAssociationsLastUpdatedAtToActivityItems < ActiveRecord::Migration
	def change
	  	add_column :activity_items, :comments_last_updated_at, :timestamp 
	  	add_column :activity_items, :likes_last_updated_at, :timestamp
	end
end