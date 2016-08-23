class AddIndexToTeamsTable < ActiveRecord::Migration
  def change
  	add_index :teams, :source_id
  	add_index :teams, :slug
  end
end
