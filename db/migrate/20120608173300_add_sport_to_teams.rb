class AddSportToTeams < ActiveRecord::Migration
  def change
    add_column :teams, :sport, :string
  end
end
