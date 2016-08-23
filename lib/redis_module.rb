module RedisModule

  def feed_last_updated_at(feed_type)
    current_time = Time.now.to_i
    last_updated_at = $redis.get self.feed_last_updated_at_key(feed_type)
    self.set_feed_last_updated_at(feed_type, current_time) if last_updated_at.nil?
    last_updated_at.nil? ? current_time : last_updated_at
  end

  def set_feed_last_updated_at(feed_type, value)
    $redis.set self.feed_last_updated_at_key(feed_type), value.to_i
  end

  def feed_last_updated_at_key(feed_type)
    "#{self.redis_feed_key(feed_type)}:updated_at"
  end

  def feed_cache_key(feed_type, starred_type, modifier_type, page_size, time_offset)
    "#{self.redis_feed_key(feed_type)}/updated_at/#{self.feed_last_updated_at(feed_type)}/starred_type/#{starred_type}/modifier_type/#{modifier_type}/page_size/#{page_size}/time_offset/#{time_offset}"
  end

  def get_mobile_feed(feed_type, starred_type, modifier_type, page_size, time_offset)
    time_offset = Time.now.to_i if time_offset.nil?
    
    normal_feed = redis_feed_key(feed_type)
    starred_feed = redis_meta_feed_key(feed_type, "starred")
    event_message_feed = redis_meta_feed_key(feed_type, "EventMessage")
      
    temp_feed_key = nil
    
    if modifier_type == "message" && starred_type == "all"
      #The set of starred event messages
      if ActivityFeed.redis_instance.zcard(starred_feed) > 0
        temp_feed_key = "#{self.redis_feed_key(feed_type)}:union:message:star:all:#{Time.now.to_i}"
        ActivityFeed.redis_instance.zinterstore(temp_feed_key, [starred_feed, event_message_feed], :weights => [1.0, 1.0], :aggregate => "max")
      end

    elsif modifier_type == "message" && starred_type.nil?
      #The set of event messages
      temp_feed_key = event_message_feed

    elsif modifier_type == "vanilla"
      #The set of normal items with starred items in-place
      temp_feed_key = normal_feed

    elsif modifier_type == nil && (starred_type == "first" || starred_type == nil)    
      #The set of starred and normal items with starred first
      if ActivityFeed.redis_instance.zcard(starred_feed) > 0
        temp_feed_key = "#{self.redis_feed_key(feed_type)}:union:star:first:#{Time.now.to_i}"
        ActivityFeed.redis_instance.zunionstore(temp_feed_key, [starred_feed, normal_feed], :weights => [2.0, 1.0], :aggregate => "max")
        tfeed = ActivityFeed.redis_instance.zrevrangebyscore(temp_feed_key, "+inf", "-inf", :with_scores => true)

        tstarred = ActivityFeed.redis_instance.zrevrange(starred_feed, 0, -1)

        if (tfeed.length > tstarred.length)
          first_starred_item = tfeed.find { |x| tstarred.include?(x[0]) == false }
          tstarred.each {|x| ActivityFeed.redis_instance.zadd(temp_feed_key, first_starred_item[1], x) }
        end
      else
        temp_feed_key = normal_feed
      end
    end

    feed = []
    unless temp_feed_key.nil? 
      feed = ActivityFeed.redis_instance.zrevrangebyscore(temp_feed_key, (time_offset.to_i).to_s, "-inf", :with_scores => true)
    end
    if feed.empty?
      return [], []
    end

    #Calculate final feed with following steps
    #Find the last item in the feed based on the page_size.
    #Get the score of this last item.
    #Find the last item in the entire feed which has the same score.
    #Return a feed from 0 upto index+1  where index is the index of the item found in the previous step.                
    if feed.length > (page_size + 2)
      score_arr = feed.map {|x| x[1]}
      score_of_last_item = score_arr[page_size-1]
      index_of_score_of_last_item = score_arr.rindex(score_of_last_item)
      feed = feed.take(index_of_score_of_last_item + 2) #Select one extra item
    end

    return get_activity_items_by_id(temp_feed_key, feed.map(&:first).map(&:to_i)), feed
  end

  def acts_as_feedable?
    true
  end

  def timestamp 
    "#{self.obj.created_at.to_i}" 
  end

  def redis_feed_key(feed_type)
    clazz = self.class.name 
    clazz = "Event" if clazz == "DemoEvent"
    
    "#{clazz}:#{self.id}:#{feed_type}"
  end

  def redis_meta_feed_key(feed_type, meta_type)
    "#{self.redis_feed_key(feed_type)}:#{meta_type.to_s}"
  end
  
  def get_activity_items_by_id(feed_key, ids)
    ais = [] 
    ids.each do |id|
      begin
        ai = ActivityItem.cache_find_by_id(id)
        ais << ai unless ai.expired
      rescue => e
        #logger.error e.message
        logger.info "Removing ActivityItem #{id} from feed #{feed_key}"
        ActivityFeed.redis_instance.zrem(feed_key, id)
      end
    end
    ais
  end
end