require 'spec_helper'

describe NotificationItem do
  describe 'factory' do
    it 'is valid' do
      FactoryGirl.build(:notification_item).valid?.should be_true
    end
  end
end
