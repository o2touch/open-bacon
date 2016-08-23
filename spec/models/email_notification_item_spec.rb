require 'spec_helper'

describe EmailNotificationItem do
	before :each do
		@ni = FactoryGirl.build :email_notification_item, :id => 1234
	end
	describe 'deliver' do
		it 'should get the mailer from the meta_data and call the method in the datum' do
			@ni.meta_data = { mailer: 'EventMailer' }
			@ni.datum = 'some_sweet_method'
			EventMailer.should_receive(:some_sweet_method).with(@ni.user_id, LandLord.default_tenant.id, hash_including(mailer: 'EventMailer')).and_return(double(deliver: nil))
			@ni.deliver
		end
	end
	describe 'deliver works with non-notification mailers' do
		it 'should get the mailer from the meta_data and call the method in the datum' do
			@ni.meta_data = { mailer: 'EventMailer' }
			@ni.datum = 'some_sweet_method'
			EventMailer.should_receive(:some_sweet_method).with(@ni.user_id, LandLord.default_tenant.id, hash_including(mailer: 'EventMailer')).and_return(double(deliver: nil))
			@ni.deliver
		end
	end
end