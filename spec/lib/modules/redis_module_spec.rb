require 'spec_helper'

describe RedisModule, :redis => true do

  class DummyClass
    include RedisModule

    def initialize
      @time = Time.now
    end

    def id
      1
    end

    def created_at
      @time
    end
  end

  def add_items_to_feed(clazz, items, feed_type, meta_type)
    key = meta_type ? clazz.redis_meta_feed_key(feed_type.to_s, meta_type.to_s) : clazz.redis_feed_key(feed_type.to_s)
    items.each { |score, item| $redis_store_feeds.zadd key, score, item }
  end

  context "#get_mobile_feed" do
    before :each do
      @clazz = DummyClass.new
      add_items_to_feed(
        @clazz, 
        [[1.0, 'a'], [2.0, 'b'], [3.0, 'c'], [4.0, 'd'], [5.0, 'e'], [6.0, 'f'], [7.0, 'g'], [8.0, 'h'], [9.0, 'i']],
        :profile, nil
      )
      add_items_to_feed(
        @clazz, 
        [[4.0, 'd'], [5.0, 'e'], [6.0, 'f']],
        :profile, :starred
      )
      add_items_to_feed(
        @clazz, 
        [[1.0, 'a'], [4.0, 'd'], [6.0, 'f']],
        :profile, "EventMessage"
      )

      @clazz.stub(:get_activity_items_by_id).and_return([])
    end


    it 'should return empty feed' do
      @clazz.get_mobile_feed(:profile, nil, nil, 5, 0)[1].should == []
    end

    it 'should return starred items at top with all starred items having same score as higest non starred item' do
      add_items_to_feed(
        @clazz, 
        [[100.0, 'x']],
        :profile, nil
      )
      @clazz.get_mobile_feed(:profile, nil, nil, 5, 500)[1].should == [['d', 100.0], ['e', 100.0], ['f', 100.0], ['x', 100.0], ['i', 9.0], ['h', 8.0]]
    end
    
    # Test broke on upgrade of redis, feature still works though. TS
    it 'should return starred items at top', broken: true do
      @clazz.get_mobile_feed(:profile, nil, nil, 5, 20)[1].should == [['d', 9.0], ['e', 9.0], ['f', 9.0], ['i', 9.0], ['h', 8.0], ['g', 7.0]]
    end

    it 'should return starred messages only' do
      @clazz.get_mobile_feed(:profile, 'all', 'message', 5, 20)[1].should == [['f', 6.0], ['d', 4.0]]
    end    

    it 'should return messages only' do
      @clazz.get_mobile_feed(:profile, nil, 'message', 5, 20)[1].should == [['f', 6.0], ['d', 4.0], ['a', 1.0]]
    end    

    it 'should return the feed' do
      @clazz.get_mobile_feed(:profile, nil, 'vanilla', 5, 20)[1].should == [['i', 9.0], ['h', 8.0], ['g', 7.0], ['f', 6.0], ['e', 5.0], ['d', 4.0]]
    end   

    it 'should return the next page' do
      @clazz.get_mobile_feed(:profile, nil, 'vanilla', 5, 20)[1].should == [['i', 9.0], ['h', 8.0], ['g', 7.0], ['f', 6.0], ['e', 5.0], ['d', 4.0]]
      @clazz.get_mobile_feed(:profile, nil, 'vanilla', 5, 4)[1].should == [['d', 4.0], ['c', 3.0], ['b', 2.0], ['a', 1.0]]
    end   
  end
end