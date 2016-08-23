class CreateEmailNotifications < ActiveRecord::Migration
  def change
    create_table :email_notifications do |t|
      t.belongs_to :notification_item
      t.references :sender
      t.string :mailer, :email_type
      t.timestamp :delivered_at
      t.timestamps
    end
  end
end
