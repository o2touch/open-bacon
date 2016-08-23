class AddClubMarketingEvents < ActiveRecord::Migration
  def change
  	create_table :club_marketing_events do |t|
  		t.integer :club_marketing_data_id
  		t.string :event_type
  		t.integer :email_id
  		t.timestamp :date
  		t.text :data

  		t.timestamps
  	end
  end
end
