require 'spec_helper'

describe Ns2NotificationItem do
	describe 'validations' do
		before :each do
			# ENI as NIs are not really meant to be instantiated
			@ni = FactoryGirl.create :email_notification_item
		end
		it 'should be valid' do
			@ni.should be_valid
		end
		it 'should require a user' do
			@ni.user = nil
			@ni.should_not be_valid
		end
		it 'should require an app_event' do
			@ni.app_event = nil
			@ni.should_not be_valid
		end
		it 'should require a datum' do
			@ni.datum = nil
			@ni.should_not be_valid
		end
	end	

	# All further tests are in queueable_spec.rb as functionality comes from
	#  the included Queueable module
end