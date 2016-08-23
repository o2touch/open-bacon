class ActivityFeed

  def self.redis_instance
    $redis_store_feeds
  end

end