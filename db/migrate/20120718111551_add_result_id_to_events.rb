class AddResultIdToEvents < ActiveRecord::Migration
  def change
    add_column :events, :result_id, :integer
  end
end
