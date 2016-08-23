require 'spec_helper'

describe ActivityItemComment do
  it 'validates the presence of the comment' do
    activity_item = ActivityItem.new
    FactoryGirl.build(:activity_item_comment, :activity_item => activity_item, :text => nil).valid?.should be_false
  end

  it 'validates the miniumum length of the comment' do
    activity_item = ActivityItem.new
    FactoryGirl.build(:activity_item_comment, :activity_item => activity_item, :text => "").valid?.should be_false
    FactoryGirl.build(:activity_item_comment, :activity_item => activity_item, :text => "x").valid?.should be_true
  end

  it 'validates the maximum length of the comment' do
    activity_item = ActivityItem.new
    FactoryGirl.build(:activity_item_comment, :activity_item => activity_item, :text => "x"*ActivityItemComment::MAXIMUM_COMMENT_LENGTH).valid?.should be_true
    FactoryGirl.build(:activity_item_comment, :activity_item => activity_item, :text => "x"*(ActivityItemComment::MAXIMUM_COMMENT_LENGTH+1)).valid?.should be_false
  end
end
