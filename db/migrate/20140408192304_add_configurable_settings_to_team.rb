class AddConfigurableSettingsToTeam < ActiveRecord::Migration
  def change
  	add_column :teams, :configurable_settings_hash, :text
  	add_column :teams, :configurable_parent_type, :string
  	add_column :teams, :configurable_parent_id, :integer
  end
end
