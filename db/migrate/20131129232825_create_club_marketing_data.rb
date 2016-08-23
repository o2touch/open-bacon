class CreateClubMarketingData < ActiveRecord::Migration
  def change
  	create_table :club_marketing_data do |t|
  		t.string :strategy
  		t.string :split
  		t.timestamp :started_at
  		t.timestamp :finished_at
  		t.timestamp :reply_at
  		t.string :contact_name
  		t.string :contact_position
  		t.string :contact_phone
  		t.string :contact_email
      t.string :twitter
      t.string :junior
  		t.text :team_contacts
  		t.text :extra

  		t.timestamps
  	end

  	add_column :clubs, :club_marketing_data_id, :integer
  end
end
