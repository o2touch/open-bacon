class CreateMobileDevices < ActiveRecord::Migration
  def change
  	create_table :mobile_devices do |t|
  		t.integer :user_id
  		t.string :token
  		t.boolean :active
  		t.boolean :logged_in
  		t.string :platform
      t.string :model
  		t.string :os_version

  		t.timestamps
  	end
  end
end
