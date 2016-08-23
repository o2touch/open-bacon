class AddFieldsToEventsTable < ActiveRecord::Migration
  def change
    add_column :events, :response_by, :integer
    add_column :events, :game_type, :integer
  end
end
