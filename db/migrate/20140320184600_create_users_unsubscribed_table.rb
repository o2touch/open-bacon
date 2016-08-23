class CreateUsersUnsubscribedTable < ActiveRecord::Migration
  def up
  	create_table :users_unsubscribed do |t|
	  	t.integer :user_id
	  	t.string :email
	  	t.timestamps
	  end
  end
  def down
  	drop_table :users_unsubscribed
  end
end
