class AddOrganiserMessageToEvents < ActiveRecord::Migration
  def change
    add_column :events, :organiser_message, :string
  end
end
