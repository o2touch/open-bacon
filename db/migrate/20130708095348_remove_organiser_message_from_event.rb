class RemoveOrganiserMessageFromEvent < ActiveRecord::Migration
  def up
    remove_column :events, :organiser_message 
  end

  def down
    add_column :events, :organiser_message, :text
  end
end