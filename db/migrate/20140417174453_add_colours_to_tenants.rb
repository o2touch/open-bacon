class AddColoursToTenants < ActiveRecord::Migration
  def change
  	add_column :tenants, :colour_1, :string
  	add_column :tenants, :colour_2, :string
  end
end
