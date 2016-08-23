require 'spec_helper'

# I wrote these tests, but they make me want to die. TS
describe TeamPusher do
	before :each do
		@pusher = TeamPusher.new
		@user = FactoryGirl.create :user, :with_mobile_device
		@team = FactoryGirl.create :team
		@tenant_id = 1
	end

	describe '#member_schedule_created' do
		it 'should send some push notifications' do
			@pusher.should_receive(:push).with({
				devices: @user.pushable_mobile_devices,
				alert: kind_of(String),
				button: "View Schedule",
				extra: {
					obj_type: "team",
					obj_id: @team.id,
					verb: "schedule_created"
				}})

			@pusher.member_schedule_created(@user.id, @tenant_id, team_id: @team.id )
		end
	end	

		describe '#member_schedule_updated' do
		it 'should send some push notifications' do
			@pusher.should_receive(:push).with({
				devices: @user.pushable_mobile_devices,
				alert: kind_of(String),
				button: "View Schedule",
				extra: {
					obj_type: "team",
					obj_id: @team.id,
					verb: "schedule_updated"
				}})

			@pusher.member_schedule_updated(@user.id, @tenant_id, team_id: @team.id )
		end
	end	
end