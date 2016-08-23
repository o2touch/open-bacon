class InviteResponse < ActiveRecord::Base
  include RedisModule
  
  belongs_to :teamsheet_entry, :counter_cache => true
  belongs_to :created_by, :class_name => 'User'
  
  has_many :activity_items, :as => :obj
  
  attr_accessible :response_status, :created_by

  after_save :touch_via_cache
  
  def touch_via_cache(time=self.updated_at)
    time = time.utc
    self.teamsheet_entry.update_attribute(:updated_at, time)
    self.teamsheet_entry.touch_via_cache(time)
    return true
  end
  
  def push_create_to_feeds
    activity_item = ActivityItem.new
    activity_item.subj = self.teamsheet_entry.user
    activity_item.obj = self
    activity_item.verb = :created
    activity_item.save!

    if !self.teamsheet_entry.event.instance_of? DemoEvent
      activity_item.push_to_newsfeeds
    end
    
    activity_item.push_to_profile_feed(self.teamsheet_entry.user)
    activity_item.push_to_profile_feed(self.teamsheet_entry.event.team)
    activity_item.push_to_activity_feed(self.teamsheet_entry.event)
  end
end
