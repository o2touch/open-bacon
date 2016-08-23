class NotificationReceipt < ActiveRecord::Base
  belongs_to :recipient, :class_name => 'User'
  belongs_to :notification, :polymorphic => true
end
