require 'connection_pool'
require 'redis'

module Onyx 
  class RedisConnection
    class << self
      def create(options={})
        url = options[:url] || Onyx::DEFAULTS[:redis_url]
        connection_pool_size = options[:connection_pool_size] || Onyx::DEFAULTS[:redis_connection_pool_size]

        ConnectionPool.new(:timeout => 1, :size => connection_pool_size) do
          build_client(url, options[:namespace], 'ruby')
        end
      end

      private

      def build_client(url, namespace, driver)
        client = Redis.connect(:url => url, :driver => driver)
        if namespace
          require 'redis/namespace'
          Redis::Namespace.new(namespace, :redis => client)
        else
          client
        end
      end
    end
  end
end
