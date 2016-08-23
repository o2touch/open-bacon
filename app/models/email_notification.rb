class EmailNotification < ActiveRecord::Base
  belongs_to :sender, :class_name => 'User'
  has_many :receipts, :class_name => 'NotificationReceipt', :as => :notification
  has_many :recipients, :through => :receipts
  belongs_to :notification_item
end
