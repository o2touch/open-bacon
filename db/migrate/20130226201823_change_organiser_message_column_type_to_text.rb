class ChangeOrganiserMessageColumnTypeToText < ActiveRecord::Migration
  def up
    change_column :events, :organiser_message, :text
  end

  def down
    change_column :events, :organiser_message, :string
  end
end
