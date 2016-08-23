class AddEventIdColumnToEventResults < ActiveRecord::Migration
  def change
    add_column :event_results, :event_id, :integer
  end
end
