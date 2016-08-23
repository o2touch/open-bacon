class MobileApps < ActiveRecord::Migration
  def change
  	create_table :mobile_apps do |t|
  		t.string :name
  		t.string :token
  	end
  end
end
