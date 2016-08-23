class FlushingStrategy
  def start(bucket)
    raise NotImplementedError.new
  end

  def notify
    raise NotImplementedError.new
  end
end
