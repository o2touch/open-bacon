module Metrics
	class Tools
		class << self

      def execute_query(query)
        mysql_results = ActiveRecord::Base.connection.execute(query)
        mysql_results.map { |r| r }
      end

    	def execute_cached_query(query, clear_cache=false)
        cache_key = Metrics::CACHE_KEY + ":query:" + Digest::SHA1.hexdigest(query)
        Rails.cache.delete(cache_key) if clear_cache

        return self.execute_query(query) if clear_cache

        results = Rails.cache.fetch(cache_key) do
          self.execute_query(query)
        end
        results
      end


		end
	end
end