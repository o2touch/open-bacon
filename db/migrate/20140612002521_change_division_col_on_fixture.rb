class ChangeDivisionColOnFixture < ActiveRecord::Migration
  def change
  	rename_column :fixtures, :division_id, :division_season_id
  end
end
