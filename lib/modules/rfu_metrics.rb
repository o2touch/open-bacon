require 'rfu_metrics/core'
require 'rfu_metrics/cache'

module RfuMetrics
  class << self

    def cache
      return Cache
    end

    def core
      return Core
    end
  end
end