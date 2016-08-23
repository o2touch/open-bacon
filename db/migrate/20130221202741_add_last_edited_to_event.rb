class AddLastEditedToEvent < ActiveRecord::Migration
  def change
  	add_column :events, :last_edited, :datetime
  end
end
