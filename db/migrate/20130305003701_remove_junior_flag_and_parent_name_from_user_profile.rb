class RemoveJuniorFlagAndParentNameFromUserProfile < ActiveRecord::Migration
  def up
	remove_column :user_profiles, :junior 
  	remove_column :user_profiles, :parent_name 
  end

  def down
  	add_column :user_profiles, :junior, :boolean
  	add_column :user_profiles, :parent_name, :string
  end
end
