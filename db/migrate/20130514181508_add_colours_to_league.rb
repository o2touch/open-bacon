class AddColoursToLeague < ActiveRecord::Migration
  def change
  	add_column :leagues, :colour1, :string
  	add_column :leagues, :colour2, :string
  end
end
