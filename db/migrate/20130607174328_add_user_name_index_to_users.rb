class AddUserNameIndexToUsers < ActiveRecord::Migration
  def change
  	add_index :users, :username, unique: true unless index_exists? :users, :username
  end
end
