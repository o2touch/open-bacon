# surprise! we actuall add app_event_id!!!!!!!!!!1! ZOMG!
class AddNs2NotificationItemIdToSmsSend < ActiveRecord::Migration
  def change
  	add_column :sms_sents, :app_event_id, :integer
  end
end
