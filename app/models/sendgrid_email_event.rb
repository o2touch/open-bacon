class SendgridEmailEvent < ActiveRecord::Base
	attr_accessible :notification_id, :email, :smtpid, :event, :category, :meta_data, :event_time
end