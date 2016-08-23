require 'spec_helper'

describe Onyx::QueueConsumer do
  it 'requeues work onto a queue' do
    call_back = Proc.new { |x| true }

    message = "message"
    queue_name = "#{SIDEKIQ_NAMESPACE}:queue:test"
    connection_pool = double('connection_pool')
    connection_pool.stub(:with) do | &block |
      block.call($redis)
    end
    
    consumer = Onyx::QueueConsumer.new(queue_name, call_back, connection_pool, 1.second, Rails.logger)
    work = Onyx::QueueConsumer::SidekiqUnitOfWork.new(queue_name, message)
    Onyx::QueueConsumer.stub(:sleep)

    consumer.requeue(work)
    $redis.rpop(queue_name).should == message
  end

  it 'polls a queue' do
    call_back = Proc.new { |x| true }
    
    message = "message"
    queue_name = "#{SIDEKIQ_NAMESPACE}:queue:test"
    $redis.stub(:brpop) #Only non-blocking calls on a test redis connection
    $redis.should_receive(:brpop).once.with(queue_name, 1).and_return([queue_name, message])
    
    connection_pool = double('connection_pool')
    connection_pool.stub(:with) do | &block |
      block.call($redis)
    end
    
    consumer = Onyx::QueueConsumer.new("#{SIDEKIQ_NAMESPACE}:queue:test", call_back, connection_pool, 1.second, Rails.logger)
    
    work = consumer.send(:poll_queue)
    work.queue.should == queue_name
    work.message.should == message
  end

  it 'consumes from a queue continuously' do
    call_back = Proc.new { |x| true }
    
    message = "message"
    queue_name = "#{SIDEKIQ_NAMESPACE}:queue:test"
    connection_pool = double('connection_pool')

    consumer = Onyx::QueueConsumer.new("#{SIDEKIQ_NAMESPACE}:queue:test", call_back, connection_pool, 1.second, Rails.logger)
    
    work = Onyx::QueueConsumer::SidekiqUnitOfWork.new(queue_name, message)
    consumer.wrapped_object.stub(:poll_queue).and_return(work)
    call_back.should_receive(:call).once.with(message)
    
    consumer.wrapped_object.stub(:after) do |interval, &block|
      consumer.wrapped_object.should_receive(:consume).once
      block.call
    end

    consumer.consume
  end

  it 'consumes from a queue continuously and stops once the terminate flag is set' do
    call_back = Proc.new { |x| true }
    
    message = "message"
    queue_name = "#{SIDEKIQ_NAMESPACE}:queue:test"
    connection_pool = double('connection_pool')
    
    consumer = Onyx::QueueConsumer.new("#{SIDEKIQ_NAMESPACE}:queue:test", call_back, connection_pool, 1.second, Rails.logger)

    work = Onyx::QueueConsumer::SidekiqUnitOfWork.new(queue_name, message)
    consumer.wrapped_object.stub(:poll_queue).and_return(work)
    call_back.should_receive(:call).twice.with(message)

    consumer.wrapped_object.stub(:after) do |interval, &block|
      consumer.shutdown
      consumer.wrapped_object.should_receive(:consume).once.and_call_original
      block.call
    end

    consumer.consume
  end

  it 'does not attempt to call the call-back if nothing is consumed from the queue' do
    call_back = Proc.new { |x| true }
    
    message = "message"
    queue_name = "#{SIDEKIQ_NAMESPACE}:queue:test"
    connection_pool = double('connection_pool')

    consumer = Onyx::QueueConsumer.new("#{SIDEKIQ_NAMESPACE}:queue:test", call_back, connection_pool, 1.second, Rails.logger)
    consumer.shutdown

    consumer.wrapped_object.stub(:poll_queue).and_return(nil)
    call_back.should_not_receive(:call)

    consumer.consume
  end

  it 'requeues messages on failure' do
    call_back = Proc.new { |x| true }
    
    message = "message"
    queue_name = "#{SIDEKIQ_NAMESPACE}:queue:test"
    connection_pool = double('connection_pool')

    consumer = Onyx::QueueConsumer.new("#{SIDEKIQ_NAMESPACE}:queue:test", call_back, connection_pool, 1.second, Rails.logger)
    consumer.shutdown

    work = Onyx::QueueConsumer::SidekiqUnitOfWork.new(queue_name, message)
    consumer.wrapped_object.stub(:poll_queue).and_return(work)
    call_back.should_receive(:call).with(work.message).and_raise(RuntimeError.new)

    consumer.wrapped_object.should_receive(:requeue).with(work)
    consumer.consume
  end
end
