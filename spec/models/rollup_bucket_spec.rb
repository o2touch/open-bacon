require 'spec_helper'
require 'sidekiq/testing'

describe RollUpBucket do
  before :each do
    @item = 'item'
    @flushing_strategy = double('flushing_strategy')
    @flushing_strategy.stub(:start)
    @message_processor = double('message_processor')
    @rollup_bucket = RollUpBucket.new('bucket', @flushing_strategy, @message_processor)
  end

  it 'accepts processable items' do
    @flushing_strategy.should_receive(:notify).once.with(@item)
    @message_processor.should_receive(:can_process?).once.with(@item).and_return(true)
    @rollup_bucket << @item
    @rollup_bucket.size.should == 1
  end

  it 'rejects unprocessable items' do
    @message_processor.should_receive(:can_process?).once.with(@item).and_return(false)
    @rollup_bucket << @item
    @rollup_bucket.size.should == 0
  end

  describe 'empty' do
    it 'returns true if the bucket is empty' do
      @rollup_bucket.empty?.should be_true
    end

    it 'returns false if the bucket is not empty' do
      @flushing_strategy.should_receive(:notify).once.with(@item)
      @message_processor.should_receive(:can_process?).once.with(@item).and_return(true)
      @rollup_bucket << @item
      
      @rollup_bucket.empty?.should be_false
    end
  end

  describe 'flush' do
    it 'flushes the bucket' do
      @flushing_strategy.should_receive(:notify).once.with(@item)
      @message_processor.should_receive(:can_process?).once.with(@item).and_return(true)
      @message_processor.should_receive(:process).once
      @rollup_bucket << @item

      @rollup_bucket.flush
      @rollup_bucket.empty?.should be_true
    end

    it 'does not flush the bucket if it is empty' do
      @message_processor.should_not_receive(:process)
      
      @rollup_bucket.flush
    end
  end
end
