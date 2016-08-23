class AddErsToNs2s < ActiveRecord::Migration
  def change
  	add_column :ns2_notification_items, :ers, :text
  end
end
