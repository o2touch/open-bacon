class SmsSent < ActiveRecord::Base
  
  attr_accessible :from, :to, :content, :teamsheet_entry_id, :user_id, :sms_reply_code, :teamsheet_entry
  attr_accessible :app_event_id
  
  has_one :sms_reply
  belongs_to :user
  belongs_to :teamsheet_entry
  belongs_to :app_event
  
  scope :without_replies, { :include => :sms_replies, :conditions => 'sms_sent.sms_reply_id IS NULL' }

  def self.generate(recipient, tse, ae)
    prev = self.where(user_id: recipient.id).last
    # sms_reply_codes should cycle 1 - 9.
    code = 0 if prev.nil?
    code = (prev.sms_reply_code % 9) + 1 unless prev.nil?

    # we don't need/user any other of the bullshit we can store, so not bothering.
    SmsSent.create!({
      user_id: recipient.id,
      teamsheet_entry_id: tse.id,
      sms_reply_code: code,
      app_event_id: ae.id
    })
  end
  
end
