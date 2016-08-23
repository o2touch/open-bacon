class ChangeTeamNameToString < ActiveRecord::Migration
  def change
    remove_column :teams, :name
    add_column :teams, :name, :string
  end
end
