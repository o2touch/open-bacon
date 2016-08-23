class AddSettingsToTeam < ActiveRecord::Migration
  def change
    add_column :teams, :settings, :text, :null => true
  end
end
