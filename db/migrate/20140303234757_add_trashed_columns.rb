class AddTrashedColumns < ActiveRecord::Migration
  def change
  	add_column :fixtures, :trashed_at, :datetime
  	add_column :results, :trashed_at, :datetime
  	add_column :points, :trashed_at, :datetime
  	add_column :data_source_links, :trashed_at, :datetime
  end
end
