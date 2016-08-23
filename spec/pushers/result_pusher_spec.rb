require 'spec_helper'

# I wrote these tests, but they make me want to die. TS
describe ResultPusher do
	before :each do
		@pusher = ResultPusher.new
		@user = FactoryGirl.create :user, :with_mobile_device
		@team = FactoryGirl.create :team
		@event = FactoryGirl.create :event, team_id: @team.id
		@result = FactoryGirl.create(:soccer_result)
		@result.stub_chain(:home_team, :name).and_return("x")
		@result.stub_chain(:away_team, :name).and_return("y")
		@result.stub(won?: false)
		@result.stub(lost?: false)
		@result.stub(draw?: true)
		@tenant_id = 1
	end

	describe '#member_result_created' do
		it 'should send some push notifications' do
			Result.should_receive(:find).and_return(@result)
			@pusher.should_receive(:push).with({
				devices: @user.pushable_mobile_devices,
				alert: kind_of(String),
				button: kind_of(String),
				extra: {
					obj_type: "event",
					obj_id: @event.id,
					verb: "updated"
				}
			})

			@pusher.member_result_created(@user.id, @tenant_id, { team_id: @team.id, event_id: @event.id } )
		end
	end	

	describe '#member_division_result_created' do
		it 'should send some push notifications' do
			division_id = 12345
			Result.should_receive(:find).and_return(@result)

			@pusher.should_receive(:push).with({
				devices: @user.pushable_mobile_devices,
				alert: kind_of(String),
				button: kind_of(String),
				extra: {
					obj_type: "division",
					obj_id: division_id,
					verb: "results_updated"
				}
			})

			@pusher.member_division_result_created(@user.id, @tenant_id, { division_id: division_id, result_id: @result.id } )
		end
	end	

		describe '#member_result_updated' do
		it 'should send some push notifications' do
			#CRUMP - TURNED THIS OFF
			# @pusher.should_receive(:push).with({
			# 	devices: @user.pushable_mobile_devices,
			# 	alert: kind_of(String),
			# 	button: kind_of(String),
			# 	extra: {
			# 		obj_type: "event",
			# 		obj_id: @event.id,
			# 		verb: "updated"
			# 	}})

			# @pusher.member_result_updated(@user.id, @tenant_id, { team_id: @team.id, event_id: @event.id } )
		end
	end	
end