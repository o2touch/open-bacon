require 'spec_helper'

describe MobileDevice do
	describe 'validations' do
		before :each do
			@device = FactoryGirl.build :mobile_device
		end
		it 'is valid from the factory' do
			@device.should be_valid
		end
		it 'must belong a user' do
			@device.user = nil
			@device.should_not be_valid
		end
		it 'must have a token' do
			@device.token = nil
			@device.should_not be_valid
		end
		it 'must have a valid platform' do
			@device.platform = "Blackberry" # ha.
			@device.should_not be_valid
		end
	end	
end