$redis = Redis.new(url: ENV['REDIS_CACHE_URL'] + '/0')
$redis_store_feeds = Redis.new(url: ENV['REDIS_STORE_URL'] + '/6')