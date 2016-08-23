class AddConfigurableSettingsToDivsAndLeagues < ActiveRecord::Migration
  def change
  	add_column :divisions, :configurable_settings_hash, :text
  	add_column :divisions, :configurable_parent_type, :string
  	add_column :divisions, :configurable_parent_id, :integer
  	add_column :leagues, :configurable_settings_hash, :text
  	add_column :leagues, :configurable_parent_type, :string
  	add_column :leagues, :configurable_parent_id, :integer
  end
end
