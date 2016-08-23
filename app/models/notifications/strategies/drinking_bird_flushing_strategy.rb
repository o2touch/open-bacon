require File.join(File.dirname(__FILE__), 'flushing_strategy')

class DrinkingBirdFlushingStrategy < FlushingStrategy
  include Celluloid

  def initialize(flushing_interval)
    @flushing_interval = flushing_interval
  end

  def start(bucket)
    @bucket = bucket
    @timer = after(@flushing_interval) { @bucket.flush }
    @activated = true
  end

  def activated?
    @activated ||= false
  end

  def notify(item)
    @timer.reset if self.activated?
  end

  private
  def timer
    @timer
  end
end
