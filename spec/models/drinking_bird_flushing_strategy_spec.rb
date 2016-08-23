# require 'spec_helper'

# describe DrinkingBirdFlushingStrategy do
#   after :all do
#     Celluloid.shutdown
#   end

#   before :each do
#     #Reset Celluloid
#     Celluloid.shutdown
#     Celluloid.boot
#   end
  
#   it 'flushes the bucket after the flushing interval lapses' do
#     sleep_interval = 1.seconds

#     flushing_strategy = DrinkingBirdFlushingStrategy.new(sleep_interval)
#     bucket = double('bucket')
#     bucket.should_receive(:flush).once.and_return(true)

#     flushing_strategy.wrapped_object.stub(:after) do |interval, &block|
#       block.call
#     end

#     flushing_strategy.start(bucket)
#     flushing_strategy.activated?.should be_true
#   end

#   it 'should not be activated on initialise' do
#     sleep_interval = 1.seconds

#     flushing_strategy = DrinkingBirdFlushingStrategy.new(sleep_interval)
#     flushing_strategy.activated?.should be_false
#   end

#   it 'resets the timer on notify' do
#     sleep_interval = 1.seconds

#     flushing_strategy = DrinkingBirdFlushingStrategy.new(sleep_interval)
#     bucket = double('bucket')
#     bucket.should_receive(:flush).once.and_return(true)

#     flushing_strategy.wrapped_object.stub(:after) do |interval, &block|
#       block.call
#     end

#     flushing_strategy.start(bucket)

#     timer = flushing_strategy.send(:timer)
#     timer.should_receive(:reset)

#     flushing_strategy.notify('item')
#   end
# end
