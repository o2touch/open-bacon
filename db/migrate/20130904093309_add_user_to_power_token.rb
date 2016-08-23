class AddUserToPowerToken < ActiveRecord::Migration
  def change
  	add_column :power_tokens, :user_id, :integer
  end
end
