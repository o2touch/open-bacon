class AddUnsubscribeToUser < ActiveRecord::Migration
  def change
    add_column :users, :unsubscribe, :boolean
  end
end
