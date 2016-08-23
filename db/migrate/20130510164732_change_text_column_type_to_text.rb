class ChangeTextColumnTypeToText < ActiveRecord::Migration
  def up
    change_column :activity_item_comments, 'text', :text
  end

  def down
    change_column :activity_item_comments, 'text', :string
  end
end
