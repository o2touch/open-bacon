class AddMobileToContactRequest < ActiveRecord::Migration
  def change
  	add_column :contact_requests, :mobile, :string
  end
end
