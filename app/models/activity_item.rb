class ActivityItem < ActiveRecord::Base 
  include CacheHelper
  
  has_many :comments, :class_name => "ActivityItemComment", :dependent => :destroy
  has_many :likes, :class_name => "ActivityItemLike", :dependent => :destroy
  has_many :likers, :class_name => "User", :through => :likes, :source => :user
 
  has_many :links, :class_name => "ActivityItemLink", :dependent => :destroy
  has_many :on_profile_feeds, :through => :links, :conditions => ['feed_type = ?', :profile]

  belongs_to :subj, :polymorphic => true
  belongs_to :obj, :polymorphic => true  
  
  attr_accessible :verb, :expired, :meta_data

  after_save :invalidate_cache

  def invalidate_cache
    Rails.cache.delete ActivityItem.static_cache_key(self.id)
  end

  #####
  # ACTIVITY FEED
  # Methods to put ActivityItems into the persistant Redis instance (ActivityFeed.redis_instance-store)
  # and push them onto the relevant activity feeds. 
  #
  # TODO: Refactor into an ActivityFeed Model
  #####
  def fetch_from_redis(object, feed_type, score=nil)
    score = self.timestamp if score.nil?
    (ActivityFeed.redis_instance.zrevrangebyscore object.redis_feed_key(feed_type), score, score).first
  end

  def push_to_redis(object, feed_type, score=nil)
    # don't allow redis to fill up with weird, unused shit. TS
    if object.is_a?(User) && feed_type.to_s == "newsfeed"
      return
    end
    
    score = self.timestamp if score.nil?

    ActivityFeed.redis_instance.zadd object.redis_feed_key(feed_type), score, self.id
    
    # write these values to a separate feed in redis
    meta_tag_to_feed = ['starred']
    # end

    #hack for now
    if self.obj.is_a? EventMessage
      ActivityFeed.redis_instance.zadd object.redis_meta_feed_key(feed_type, "EventMessage"), score, self.id
    end

    unless self.meta_data.nil?
      meta_data = JSON.parse(self.meta_data)
      if meta_data.is_a? Hash
        meta_tag_to_feed.each do |x|
          if meta_data.keys.include?(x)
            if meta_data['starred'] == false
              ActivityFeed.redis_instance.zrem object.redis_meta_feed_key(feed_type, x), self.id
            else
              ActivityFeed.redis_instance.zadd object.redis_meta_feed_key(feed_type, x), score, self.id
            end
          end
        end
      end
    end

    object.set_feed_last_updated_at(feed_type, Time.now)
  end

  def push_to_activity_feed(object)
    feed_type = :activity
    self.push_to_demo_activity_feed(object)
    self.send_push_notification(feed_type, object, "add")
    score = self.timestamp

    push_to_redis(object, feed_type, score)
    return true
  end

  def push_to_demo_activity_feed(object)
    if object.nil? #remove this if block, this should never be the case and if it is then an error should throw
      return false
    end
    
    feed_type = :activity
    
    link = ActivityItemLink.new
    link.feed_owner = object
    link.activity_item = self
    link.feed_type = feed_type
    link.save!
    
    #score = self.timestamp
    #ActivityFeed.redis_instance.zadd object.redis_feed_key(feed_type), score, self.id
    return true
  end
  
  def push_to_profile_feed(object)
    if object.nil? #remove this if block, this should never be the case and if it is then an error should throw
      return false
    end
    
    feed_type = :profile
    
    link = ActivityItemLink.new
    link.feed_owner = object
    link.activity_item = self
    link.feed_type = feed_type
    link.save!
    
    self.send_push_notification(feed_type, object, "add")

    score = self.timestamp

    push_to_redis(object, feed_type, score)
    return true
  end
  
  def push_to_newsfeed(object)
    # stop redis getting filled up with shit
    return if object.is_a? User
    feed_type = :newsfeed

    @feed_type = feed_type

    score = self.timestamp

    push_to_redis(object, feed_type, score)
  end
  
  def push_to_newsfeeds
    self.interested_users.each do |user|
      self.push_to_newsfeed(user)
    end
  end
  #####
  # END ACTIVITY FEEDS
  #####
  
  def interested_users
    users = []
    if self.subj.is_a?(User)
      users.concat(self.subj.friends)
    end
    if self.obj.is_a?(User)
      users.concat(self.obj.friends)
    end
    users.uniq
  end
  
  def create_comment(user,text)
    comment = ActivityItemComment.new
    comment.user = user
    comment.text = text
    comment.activity_item = self
    comment.save!
    comment
  end
  
  def create_like(user)
    like = ActivityItemLike.new
    like.user = user
    like.activity_item = self
    like.save!
    like
  end

  def delete_like(user)
    likes = self.likes.where(:activity_item_id => self.id, :user_id => user.id)
    likes.each { |l| l.destroy }
    self.save
  end

  def send_push_notification(feed_type, object, type="add", socketID=nil)
    ActivityItem.delay_for(1.seconds, queue: 'pusher').send_push_notification(self.id, feed_type, object.id, object.class.name, type, socketID)
  end

  def self.send_push_notification(id, feed_type, object_id, object_type, type="add", socketID=nil)
    # We pass the object id but we think it's not really needed here. There is an engineering task to remove this.
    ai = ActivityItem.find(id)
    logger.info "IN ACTIVITY PUSH NOTIFICATION"

    # TODO SR - Extract into class and mock it out.
    rabl_out = Rabl::Renderer.new('api/v1/activity_items/show', ai, :view_path => 'app/views', :format => 'hash', :scope => BFFakeContext.new).render
    
    if object_type == Team.name || object_type == DivisionSeason.name #We want to remove profile feed_type but for now this nasty hack
      feed_type = "activity"
    end

    name = "#{object_type.downcase}-#{object_id.to_s}-#{feed_type}" 
    Pusher[name].trigger(
      type + '_activity_item',
      rabl_out,
      socketID
    )
  end

  def timestamp
    "#{self.created_at.to_i}"
  end
  
  # DEPRECATED
  def push_to_feed(object,feed_type)
    self.push_to_profile_feed(object)
  end 

  def rabl_cache_key
    key_extension = self.updated_at ? "#{self.comments_last_updated_at.utc.to_s(:number)}/#{self.likes_last_updated_at.utc.to_s(:number)}" : "none"
    subj_key_extension = "none"
    obj_key_extension = "none"
    event_key_extension =  "none"
    if (self.obj_type == "TeamsheetEntry") || (self.obj_type == "InviteReminder") 
      event_key_extension = self.obj.event.rabl_cache_key unless (self.obj.nil? || self.obj.event.nil?)
    end

    if (self.obj_type == "EventMessage")
      unless (self.obj.nil? || self.obj.messageable.nil?)
        event_key_extension = self.obj.respond_to?(:rabl_cache_key) ? self.obj.messageable.rabl_cache_key : self.obj.messageable.cache_key
      end
    end

    if (self.obj_type == "Event") 
      event_key_extension = self.obj.rabl_cache_key unless self.obj.nil?
    end

    subj_key_extension = ((self.subj.respond_to?(:rabl_cache_key)) ? self.subj.rabl_cache_key : self.subj.cache_key) unless self.subj.nil?
    obj_key_extension = ((self.obj.respond_to?(:rabl_cache_key)) ? self.obj.rabl_cache_key : self.obj.cache_key) unless self.obj.nil?
    "#{self.cache_key}/#{key_extension}/#{subj_key_extension}/#{obj_key_extension}/#{event_key_extension}"
  end

  def self.cache_find_by_id(id)
    ActivityItem
    cache_key = ActivityItem.static_cache_key(id)
    begin
      Rails.cache.fetch cache_key do
        ActivityItem.find(id)    
      end
    rescue
      ActivityItem.find(id)
    end
  end
  
  def comments_last_updated_at
    fetch_from_cache "#{self.cache_key}/comments_last_updated_at" do
      self.updated_at ? self.updated_at : Time.Now
    end
  end

  def comments_last_updated_at=(value)
    Rails.cache.write "#{self.cache_key}/comments_last_updated_at", value
    self.set_feed_last_updated_at(Time.now)
  end

  def cached_comments
    ActivityItemComment      
    cache_key = "#{self.cache_key}/#{self.comments_last_updated_at.utc.to_s(:number)}/ActivityItemComment"
    fetch_from_cache cache_key do
      self.comments(true)
    end
  end

  def likes_last_updated_at
    fetch_from_cache "#{self.cache_key}/likes_last_updated_at" do
      self.updated_at ? self.updated_at : Time.Now
    end
  end

  def likes_last_updated_at=(value)
    Rails.cache.write "#{self.cache_key}/likes_last_updated_at", value
    self.set_feed_last_updated_at(Time.now)
  end

  def set_feed_last_updated_at(time)
    obj = nil
    feed_type = nil
    if self.obj.is_a? EventMessage
      obj = self.obj.messageable
      feed_type = self.obj.messageable.is_a?(Team) ? :profile : :activity
    else
      obj = self.obj 
      feed_type = self.obj.is_a?(Event) ? :activity : :profile
    end

    obj.set_feed_last_updated_at(feed_type, Time.now) if obj.respond_to? :set_feed_last_updated_at
  end 


  def cached_likes
    ActivityItemLike
    cache_key = "#{self.cache_key}/#{self.likes_last_updated_at.utc.to_s(:number)}/ActivityItemLike"
    fetch_from_cache cache_key do
      self.likes(true)
    end
  end

  def user_has_liked?(user)
    return false if user.nil? 
    self.cached_likes.each { |l| return true if user.id==l.user_id }
    false
  end

  def self.static_cache_key(id)
    "ActivityItem/#{id}"
  end  
end