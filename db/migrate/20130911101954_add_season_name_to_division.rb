class AddSeasonNameToDivision < ActiveRecord::Migration
  def change
  	add_column :divisions, :season_name, :string
  	add_column :divisions, :current_season, :boolean, default: true
  end
end
