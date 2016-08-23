class RemoveAssocationsLastUpdatedAt < ActiveRecord::Migration
  def up
  	  remove_column :teams, :events_last_updated_at if column_exists? :teams, :events_last_updated_at
  		remove_column :teams, :team_roles_last_updated_at if column_exists? :teams, :team_roles_last_updated_at
  	  remove_column :events, :teamsheet_entries_last_updated_at if column_exists? :events, :teamsheet_entries_last_updated_at
  		remove_column :users, :team_roles_last_updated_at if column_exists? :users, :team_roles_last_updated_at
  		remove_column :users, :events_last_updated_at if column_exists? :users, :events_last_updated_at
  	  remove_column :activity_items, :comments_last_updated_at if column_exists? :activity_items, :comments_last_updated_at
  		remove_column :activity_items, :likes_last_updated_at if column_exists? :activity_items, :likes_last_updated_at
  end
end
