require 'spec_helper'

class MockGoalCheckListItem < GoalCheckListItem 
  def initialize(key)
    @key = key
  end

  def key
    @key
  end
end

describe GoalChecklist do
  describe 'add_item' do
    it 'accepts checklist items' do
      checklist = GoalChecklist.new
      checklist.get_items.count.should == 0
      checklist.add_item(MockGoalCheckListItem.new("item 2"))
      checklist.get_items.count.should == 1
    end

    it 'rejects non-checklist items' do
      checklist = GoalChecklist.new
      expect { checklist.add_item(1) }.to raise_error
    end

    it 'adds items with unique keys only' do
      checklist = GoalChecklist.new
      item = MockGoalCheckListItem.new("item 1")
      checklist.add_item(item)
      checklist.add_item(item)
      checklist.get_items.count.should == 1
    end
  end

  describe 'get_item' do
    it 'returns checklist items' do
      checklist = GoalChecklist.new
      item = MockGoalCheckListItem.new("item 1")
      checklist.add_item(item)
      checklist.get_item(item.key).should == item
    end
  end

  describe 'notify' do
    it 'triggers pusher notifications for each checklist item' do
      checklist = GoalChecklist.new
      
      item_one = MockGoalCheckListItem.new("item 1")
      item_two = MockGoalCheckListItem.new("item 2")
      checklist.add_item(item_one)
      checklist.add_item(item_two)

      item_one.should_receive(:notify).exactly(1).times
      item_two.should_receive(:notify).exactly(1).times
      
      #Pusher.should_receive(:[]).exactly(checklist.get_items.count).times.and_return(double(trigger: true))

      checklist.notify
    end
  end
end
