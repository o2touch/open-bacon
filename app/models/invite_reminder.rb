##########
# THIS IS NO LONGER USED!
# 
# Not deleted as it's in the feeds, and we don't want to have to go through
#  and delete all these kind of acitivity items (though this should be done)
#  at some point.
#
# No further InviteReminders will be created.
#
# TODO: Go through the project and remove all trace of this nonsense.
#
# TS.
#############
class InviteReminder < ActiveRecord::Base
  include RedisModule
  
  belongs_to :teamsheet_entry
  
  has_one :event, :through => :teamsheet_entry
  has_one :user, :through => :teamsheet_entry
  has_one :user_sent_by, :class_name => "User"
  has_many :activity_items, :as => :obj

  attr_accessible :teamsheet_entry, :user_sent_by
  
  after_create :send_reminder

  def send_reminder
    # DOESNT WORK?! Was because of an exception in user mailer. fixed.
    #UserMailer.delay.invite_reminder(self)
    self.push_create_to_feeds()
  end

  def push_create_to_feeds
    activity_item = ActivityItem.new
    activity_item.subj = self.user
    activity_item.obj = self
    activity_item.verb = :sent
    activity_item.save!
       
    activity_item.push_to_activity_feed(self.event)

    activity_item
  end
end
