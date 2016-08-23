class CreateSendgridEmailEvent < ActiveRecord::Migration
  def change
  	create_table :sendgrid_email_events do |t|
  		t.string :id
  		t.string :email_notification_id
  		t.string :email
  		t.string :smtpid
  		t.string :event
  		t.string :category
  		t.string :meta_data
  		t.timestamp :event_time

  		t.timestamps
  	end
  end
end
