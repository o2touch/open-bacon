class CreateNotificationReceipts < ActiveRecord::Migration
  def change
    create_table :notification_receipts do |t|
      t.references :notification, :polymorphic => true
      t.references :recipient
      t.timestamp :delivered_at
      t.timestamps
    end
  end
end
