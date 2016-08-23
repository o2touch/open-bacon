class DropAlienShit < ActiveRecord::Migration
  def up
    drop_table :data_source_links
    drop_table :faft_instructions_2
    drop_table :faft_instructions_2_archive
    drop_table :transaction_items
    drop_table :transaction_item_dependencies
    drop_table :transaction_item_archive
    # extra little bonus here
    drop_table :old_users
  end
end
