class AddTimestampToEventsTable < ActiveRecord::Migration
  def change
    change_column :events, :time, :timestamp
  end
end
