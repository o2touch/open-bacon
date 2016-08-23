class AddUuidToTeams < ActiveRecord::Migration
  def change
    add_column :teams, :uuid, :string
  end
end
