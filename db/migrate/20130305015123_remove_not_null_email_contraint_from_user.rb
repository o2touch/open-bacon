class RemoveNotNullEmailContraintFromUser < ActiveRecord::Migration
  def up
  	change_column :users, :email, :string, :null => true
  end

  def down
  	change_column :users, :address, :string, :null => false
  end
end
