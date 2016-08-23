class AddAlienColsToFixedDivision < ActiveRecord::Migration
  def change
  	add_column :fixed_divisions, :rank, :integer
  	add_column :fixed_divisions, :source, :string
  	add_column :fixed_divisions, :source_id, :integer
  	add_column :fixed_divisions, :tenant_id, :integer
  end
end
