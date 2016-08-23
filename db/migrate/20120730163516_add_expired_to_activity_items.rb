class AddExpiredToActivityItems < ActiveRecord::Migration
  def change
    add_column :activity_items, :expired, :integer
  end
end
