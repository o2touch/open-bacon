class AddSlugIndexToLeague < ActiveRecord::Migration
  def change
  	add_index :leagues, :slug, unique: true
  end
end
