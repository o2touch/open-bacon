class ActivityItemLike < ActiveRecord::Base
  
  belongs_to :activity_item
  belongs_to :user
  after_save :touch_via_cache
  before_destroy { |x| x.touch_via_cache(Time.now) }

  attr_accessible :activity_item_id, :user_id
  
  def touch_via_cache(time=self.updated_at)
    self.activity_item.likes_last_updated_at = time.utc
    return true
  end
end
