#Implementation based on Sidekiq Fetcher/Poller classes

module Onyx
  class QueueConsumer
    include Celluloid

    def initialize(queue_name, call_back, redis_connection=nil, polling_interval=nil, logger=nil)
      @queue_name = queue_name
      @call_back = call_back
      @polling_interval = polling_interval || 2
      @redis = redis_connection || Onyx.redis 
      @logger = logger || Onyx.logger
      @terminate = false
    end

    def consume
      unit_of_work = nil
      begin
        unit_of_work = poll_queue
        if unit_of_work
          @logger.debug "Consumed item from #{@queue_name}"
          @call_back.call(unit_of_work.message)
          @logger.info "Processed item from #{@queue_name}"
        else
          @logger.debug "Nothing to consume from #{@queue_name}"
        end
      rescue => e
        @logger.info "Error fetching message: #{e}"
        e.backtrace.each do |b|
          @logger.info b
        end

        if unit_of_work
          self.requeue(unit_of_work)
          @logger.info "Requeued item to #{@queue_name}"
        end
      end

      after(@polling_interval) { self.consume } unless @terminate
    end

    def requeue(unit_of_work)
      sleep(@polling_interval)
      @redis.with { |connection| connection.rpush("#{SIDEKIQ_NAMESPACE}:queue:#{unit_of_work.queue_name}", unit_of_work.message) }
    end

    def shutdown 
      @terminate = true
    end

    #Pinched from Sidekiq
    SidekiqUnitOfWork = Struct.new(:queue, :message) do
      def queue_name
        queue.gsub(/.*queue:/, '')
      end
    end

    private
    def poll_queue
      @logger.info "Polling #{@queue_name}"
      work = @redis.with { |connection| connection.brpop(@queue_name, 1) }
      SidekiqUnitOfWork.new(*work) if work
    end
  end
end
