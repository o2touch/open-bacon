class AddFieldsToTeams < ActiveRecord::Migration
  def change
    add_column :teams, :created_by_id, :integer
    add_column :teams, :name, :integer
  end
end
