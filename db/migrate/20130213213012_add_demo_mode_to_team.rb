class AddDemoModeToTeam < ActiveRecord::Migration
  def change
  	add_column :teams, :demo_mode, :integer, :default => 0
  end
end
