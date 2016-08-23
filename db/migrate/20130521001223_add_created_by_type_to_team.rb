class AddCreatedByTypeToTeam < ActiveRecord::Migration
  def change
  	add_column :teams, :created_by_type, :string
  end
end
