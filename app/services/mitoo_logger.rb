class MitooLogger
  def self.valid_fail(message=nil)
    @my_log ||= Logger.new("#{Rails.root}/log/valid_fails.log")
    @my_log.info(message) unless message.nil?
  end
end