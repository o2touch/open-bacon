#####
#
# RFUMetrics::Cache
#
# This class is a caching wrapper around the RFUMetrics::Core class. Used in:
# - the API reporting controllers to serve cached data
# - cron tasks to bust the respective caches
# 
#####
module RfuMetrics
  class Cache
    class << self

      # Here we wrap any method on the Core class in a cache
      def method_missing(method_sym, *arguments, &block)
        if Core.respond_to?(method_sym)      
          cache_key = get_cache_key(method_sym, arguments)

          # Removes the argument needed for this method
          force = arguments.pop

          data = Rails.cache.fetch(cache_key, force: force) do
            Core.send(method_sym, *arguments)
          end

        return data
        else
          super
        end
      end

      def get_cache_key(method_name, arguments)
        key = "rfu_metrics_#{method_name}"
        arguments.each do |arg|
          key += "_" + arg.strftime("%m_%y") if arg.respond_to? :strftime
        end
        key
      end

    end
  end
end