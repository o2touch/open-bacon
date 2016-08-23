class AddFeedTypeToActivityItemLink < ActiveRecord::Migration
  def change
    add_column :activity_item_links, :feed_type, :string
  end
end
