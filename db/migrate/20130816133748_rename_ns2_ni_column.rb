class RenameNs2NiColumn < ActiveRecord::Migration
  def change
  	rename_column :ns2_notification_items, :sent_at, :processed_at
  end
end
