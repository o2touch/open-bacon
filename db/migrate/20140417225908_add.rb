class Add < ActiveRecord::Migration
  def up
  	add_column :fixtures, :tenant_id, :integer
  end
end
