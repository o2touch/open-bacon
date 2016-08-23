class AddLookupIndexToActivityItemComments < ActiveRecord::Migration
  def change
    add_index "activity_item_comments", ["activity_item_id"]
  end
end
