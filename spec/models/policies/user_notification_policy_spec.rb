require 'spec_helper'

describe UserNotificationsPolicy do
	before :each do
		@u = double(:user)
		@t = double(:tenant)

		@u.stub(email: "tim@gmail.org.uk")
		@u.stub(mobile_number: "+447793966182")
		@u.stub(pushable_mobile_devices: ["hi"])

		@t.stub(email: true)
		@t.stub(sms: true)
		@t.stub(mobile_app: "hi")
	end
	
	context 'initialization' do
		context 'sms' do
			it 'does not sms if user has not phone' do
				@u.stub(mobile_number: nil)
				UserNotificationsPolicy.new(@u, @t).can_sms?.should be_false
			end
			it 'does not sms if tenant disabled' do
				@t.stub(sms: false)
				UserNotificationsPolicy.new(@u, @t).can_sms?.should be_false
			end
			it 'does not sms if both disabled' do
				@t.stub(sms: false)
				@u.stub(mobile_number: nil)
				UserNotificationsPolicy.new(@u, @t).can_sms?.should be_false
			end
			it 'does sms if both enabled' do
				UserNotificationsPolicy.new(@u, @t).can_sms?.should be_true
			end
		end

		context 'email' do
			it 'does not email if user has no email address' do
				@u.stub(email: nil)
				UserNotificationsPolicy.new(@u, @t).can_email?.should be_false
			end
			it 'does not email if tenant disabled' do
				@t.stub(email: false)
				UserNotificationsPolicy.new(@u, @t).can_email?.should be_false
			end
			it 'does not email if both disabled' do
				@t.stub(email: false)
				@u.stub(email: nil)
				UserNotificationsPolicy.new(@u, @t).can_email?.should be_false
			end
			it 'does email if both enabled' do
				UserNotificationsPolicy.new(@u, @t).can_email?.should be_true
			end
		end

		context 'push' do
			it 'does not push if user has not applicable mobile devices' do
				@u.stub(pushable_mobile_devices: [])
				UserNotificationsPolicy.new(@u, @t).can_push?.should be_false
			end
			it 'does not push if tenant has not mobile app' do
				@t.stub(mobile_app: nil)
				UserNotificationsPolicy.new(@u, @t).can_push?.should be_false
			end
			it 'does not push if both of the above' do
				@u.stub(pushable_mobile_devices: [])
				@t.stub(mobile_app: nil)
				UserNotificationsPolicy.new(@u, @t).can_push?.should be_false
			end
			it 'does push if mobile app, and mobile device' do
				UserNotificationsPolicy.new(@u, @t).can_push?.should be_true
			end
		end
	end

	context 'priority' do
		context 'when push, sms and email enabled' do
			before :each do
				@unp = UserNotificationsPolicy.new(@u, @t)
			end
			it 'should push' do
				@unp.should_push?.should be_true
			end
			it 'should not email' do
				@unp.should_email?.should be_false
			end
			it 'should not sms' do
				@unp.should_sms?.should be_false
			end
		end
		context 'when only email and sms enabled' do
			before :each do
				@u.stub(pushable_mobile_devices: [])
				@unp = UserNotificationsPolicy.new(@u, @t)
			end
			it 'should not push' do
				@unp.should_push?.should be_false
			end
			it 'should email' do
				@unp.should_email?.should be_true
			end
			it 'should not sms' do
				@unp.should_sms?.should be_false
			end
		end
		context 'when only push and sms enabled' do
			before :each do
				@u.stub(email: nil)
				@unp = UserNotificationsPolicy.new(@u, @t)
			end
			it 'should push' do
				@unp.should_push?.should be_true
			end
			it 'should not email' do
				@unp.should_email?.should be_false
			end
			it 'should not sms' do
				@unp.should_sms?.should be_false
			end
		end
		context 'when only push and email enabled' do
			before :each do
				@u.stub(mobile_number: nil)
				@unp = UserNotificationsPolicy.new(@u, @t)
			end
			it 'should push' do
				@unp.should_push?.should be_true
			end
			it 'should not email' do
				@unp.should_email?.should be_false
			end
			it 'should not sms' do
				@unp.should_sms?.should be_false
			end
		end
		context 'when only sms enabled' do
			before :each do
				@u.stub(pushable_mobile_devices: [])
				@u.stub(email: nil)
				@unp = UserNotificationsPolicy.new(@u, @t)
			end
			it 'should not push' do
				@unp.should_push?.should be_false
			end
			it 'should not email' do
				@unp.should_email?.should be_false
			end
			it 'should not sms' do
				@unp.should_sms?.should be_true
			end
		end
	end

	context 'should_notify' do
		it 'should notify' do
			UserNotificationsPolicy.new(@u, @t).should_notify?.should be_true	
		end
	end
end