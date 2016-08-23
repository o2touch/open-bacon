class SmsReply < ActiveRecord::Base
  
  belongs_to :teamsheet_entry
  belongs_to :sms_sent
  
  attr_accessible :content, :number
  
  
end
