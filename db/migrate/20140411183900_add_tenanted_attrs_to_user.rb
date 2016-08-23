class AddTenantedAttrsToUser < ActiveRecord::Migration
  def change
  	add_column :users, :tenanted_attrs, :text
  	add_column :users, :configurable_settings_hash, :text
  	add_column :users, :configurable_parent_type, :string
  	add_column :users, :configurable_parent_id, :integer
  end
end
