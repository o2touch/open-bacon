class AddRfuFieldsToUser < ActiveRecord::Migration
  def change
  	add_column :user_profiles, :gender, :string
  	add_column :user_profiles, :dob, :date
  	add_column :user_profiles, :location_id, :integer
  end
end
