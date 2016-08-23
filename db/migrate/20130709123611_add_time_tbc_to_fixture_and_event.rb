class AddTimeTbcToFixtureAndEvent < ActiveRecord::Migration
  def change
  	add_column :events, :time_tbc, :boolean, default: false
  	add_column :fixtures, :time_tbc, :boolean
  end
end
