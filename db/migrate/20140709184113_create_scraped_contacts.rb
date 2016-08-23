class CreateScrapedContacts < ActiveRecord::Migration
  def change
  	create_table :scraped_contacts do |t|
  		t.string :name
  		t.string :email
  		t.string :phone
  		t.string :contact_link
  		t.string :position
  		t.string :address
  		t.string :org_type
  		t.integer :org_id

  		t.timestamps
  	end
  end
end
