class AddParentNameAndJuniorsToUsers < ActiveRecord::Migration
  def change
    add_column :user_profiles, :parent_name, :string
    add_column :user_profiles, :junior, :integer
  end
end
