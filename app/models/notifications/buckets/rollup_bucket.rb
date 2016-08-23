class RollUpBucket
  def initialize(name, flushing_strategy, message_processor)
    @name = name
    @items = []
    @flushing_strategy = flushing_strategy
    @message_processor = message_processor
    @semaphore = Mutex.new

    @flushing_strategy.start(self)
  end

  def <<(item)
    return false unless @message_processor.can_process?(item)

    @semaphore.synchronize do
      @items << (item)
      @flushing_strategy.notify(item)
    end

    true
  end
  alias_method :add_item, :<<

  def empty?
    @items.empty?
  end

  def size
    @items.size
  end

  def flush 
    if self.size > 0
      @semaphore.synchronize do
        flushed_items = []
        if self.size > 0
          flushed_items = @items.clone
          @items.clear
          @message_processor.process(flushed_items)
        end
      end
    end
  end
end
