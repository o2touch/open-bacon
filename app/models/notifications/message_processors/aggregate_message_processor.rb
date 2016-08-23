class AggregateMessageProcessor
  def process(messages)
    raise NotImplementedError.new
  end

  def transform(message)
    raise NotImplementedError.new
  end

  def can_process?(message)
    raise NotImplementedError.new
  end
end
