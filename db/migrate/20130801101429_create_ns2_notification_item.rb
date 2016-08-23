class CreateNs2NotificationItem < ActiveRecord::Migration
  def change
  	create_table :ns2_notification_items do |t|
  		t.string :type # sti column
  		t.integer :app_event_id
  		t.integer :user_id
  		t.string :medium
  		t.string :datum
  		t.text :meta_data
  		t.integer :timeout
  		t.timestamp :sent_at

  		t.timestamps
  	end
  end
end
