class CreateActiveCampaignEventTable < ActiveRecord::Migration
  def change
  	create_table :active_campaign_events do |t|
  		t.string :id
  		t.string :email
  		t.string :user_id
      t.string :contact_id
  		t.string :event
  		t.string :list_id
  		t.string :campaign_id
      t.string :ip
  		t.string :meta_data
  		t.timestamp :event_time

  		t.timestamps
  	end
  end
end
