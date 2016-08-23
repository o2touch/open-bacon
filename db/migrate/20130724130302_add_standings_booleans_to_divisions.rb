class AddStandingsBooleansToDivisions < ActiveRecord::Migration
  def change
  	add_column :divisions, :track_results, :boolean, default: false
  	add_column :divisions, :show_standings, :boolean, default: false
  end
end
