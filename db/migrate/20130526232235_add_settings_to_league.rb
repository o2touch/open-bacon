class AddSettingsToLeague < ActiveRecord::Migration
  def change
    add_column :leagues, :settings, :text, :null => true
  end
end
