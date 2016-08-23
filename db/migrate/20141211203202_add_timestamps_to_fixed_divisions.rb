class AddTimestampsToFixedDivisions < ActiveRecord::Migration
  def change
    add_column :fixed_divisions, :created_at, :datetime
    add_column :fixed_divisions, :updated_at, :datetime
  end
end
