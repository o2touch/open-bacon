class AddTimeZoneToLeague < ActiveRecord::Migration
  def change
  	add_column :leagues, :time_zone, :string
  end
end
