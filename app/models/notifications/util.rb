module Onyx
  module Util
    def redis(&block)
      Onyx.redis(&block)
    end
  end
end
