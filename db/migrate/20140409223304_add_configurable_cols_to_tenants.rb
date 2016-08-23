class AddConfigurableColsToTenants < ActiveRecord::Migration
  def change
  	add_column :tenants, :configurable_settings_hash, :text
  	add_column :tenants, :configurable_parent_type, :string
  	add_column :tenants, :configurable_parent_id, :integer
  end
end
