class AddFieldsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :profile_picture_uid, :string
  end
end
