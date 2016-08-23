class AddTenantShitToClubs < ActiveRecord::Migration
  def change
   	add_column :clubs, :configurable_settings_hash, :text
  	add_column :clubs, :configurable_parent_type, :string
  	add_column :clubs, :configurable_parent_id, :integer
  	add_column :clubs, :tenant_id, :integer
  end
end
