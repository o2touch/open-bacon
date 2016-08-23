class AddLookupIndexToActivityItemLikes < ActiveRecord::Migration
  def change
    add_index "activity_item_likes", ["activity_item_id"]
  end
end
