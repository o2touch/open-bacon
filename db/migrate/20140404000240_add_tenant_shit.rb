class AddTenantShit < ActiveRecord::Migration
  def change
  	create_table :tenants do |t|
  		t.string :name
  		t.string :subdomain
  		t.string :logo
  		t.text :settings
  		t.timestamps
  	end

  	add_column :users, :tenant_id, :integer
  	add_column :teams, :tenant_id, :integer
  	add_column :divisions, :tenant_id, :integer
  	add_column :leagues, :tenant_id, :integer
  	add_column :mobile_devices, :tenant_id, :integer
  	add_column :events, :tenant_id, :integer
  end
end
