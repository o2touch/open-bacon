class AddSlugsToTeamsAndDivisionsTable < ActiveRecord::Migration
  def up
  	add_column :divisions, :slug, :string
  	add_column :teams, :slug, :string
  end

  def down
  	remove_column :divisions, :slug
  	remove_column :teams, :slug
  end
end
