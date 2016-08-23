class CreateUserFullContactDetails < ActiveRecord::Migration
  def change
    create_table :user_full_contact_details do |t|
      t.string :email
      t.string :photo_url
      t.string :full_contact_json

      t.timestamps
    end
  end
end
