class AddResponseRequiredToEvent < ActiveRecord::Migration
  def change
  	add_column :events, :response_required, :boolean, default: true
  end
end
