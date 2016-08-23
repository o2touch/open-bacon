class ActivityItemComment < ActiveRecord::Base
  
  MAXIMUM_COMMENT_LENGTH = 4000
  MINIMUM_COMMENT_LENGTH = 1

  belongs_to :activity_item
  belongs_to :user
  after_save :touch_via_cache
  before_destroy { |x| x.touch_via_cache(Time.now) }
  attr_accessible :activity_item_id, :text, :user_id

  validates :text, :user, :activity_item, presence: true
  validates_length_of :text, :minimum => MINIMUM_COMMENT_LENGTH, :maximum => MAXIMUM_COMMENT_LENGTH, :allow_blank => false

  def touch_via_cache(time=self.updated_at)
    self.activity_item.comments_last_updated_at = time.utc unless self.activity_item.nil?
    return true
  end
  
  # TODO: This whole method should be in EventsNotificationService
  def send_notifications
    users_to_email = self.activity_item.comments.map{ |comment| comment.user }
  	users_to_email << activity_item.subj if activity_item.subj.is_a?(User)
  	users_to_email.delete self.user
  	users_to_email.uniq!

    thread = self.activity_item.comments

    # TODO: Move to event notification system - TS
    users_to_email.each do |user|
      UserMailer.delay.comment_posted(user, self, thread, self.activity_item)
    end 
    users_to_email
  end
end
