require 'spec_helper'

# I wrote these tests, but they make me want to die. TS
describe EventPusher do
	before :each do
		@pusher = EventPusher.new
		@user = FactoryGirl.create :user, :with_mobile_device
		@event_id = 1

		@team = FactoryGirl.create(:team)
		@mock_event = FactoryGirl.create :event, :team => @team

		@tenant_id = 1

		Event.stub(:find).and_return(@mock_event)
	end

	describe '#member_event_postponed' do
		before :each do

			old_value = @mock_event.time
			new_value = @mock_event.time

			@data = {
				event_id: @event_id,
				diff_map: {
					time: [old_value, new_value]
				}
			}
		end

		it 'should send some push notifications' do
			Event.should_receive(:find).with(@event_id)
			@pusher.should_receive(:push).with({
				devices: @user.pushable_mobile_devices,
				alert: kind_of(String),
				button: "View Event",
				extra: {
					"obj_type" => "event",
					"obj_id" => @event_id,
					"verb" => "postponed"
				}})

			@pusher.member_event_postponed(@user.id, @tenant_id, @data)
		end
	end	

	describe '#member_event_rescheduled' do
		before :each do
			@old_value = @mock_event.time
			@new_value = @mock_event.time + 7.days

			@mock_event.time = @new_value

			@data = {
				event_id: @event_id,
				diff_map: {
					time: [@old_value, @new_value]
				}
			}
		end
		it 'should send some push notifications' do
			Event.should_receive(:find).with(@event_id)
			@pusher.should_receive(:push).with({
				devices: @user.pushable_mobile_devices,
				alert: kind_of(String),
				button: "View Event",
				extra: {
					"obj_type" => "event",
					"obj_id" => @event_id,
					"verb" => "rescheduled"
				}}).and_call_original

			push = @pusher.member_event_rescheduled(@user.id, @tenant_id, @data)

			old_time_str = BFTime.new(@new_value, @mock_event.time_zone, @mock_event.time_tbc).pp_sms_time
			push.data[:alert].should match(old_time_str)
		end

		context "when diff_map does not exist" do
			before :each do
				@data[:diff_map] = nil
			end
			it 'should send some push notifications' do
			Event.should_receive(:find).with(@event_id)
			@pusher.should_receive(:push).with({
				devices: @user.pushable_mobile_devices,
				alert: kind_of(String),
				button: "View Event",
				extra: {
					"obj_type" => "event",
					"obj_id" => @event_id,
					"verb" => "rescheduled"
				}}).and_call_original

			push = @pusher.member_event_rescheduled(@user.id, @tenant_id, @data)

			old_time_str = BFTime.new(@new_value, @mock_event.time_zone, @mock_event.time_tbc).pp_sms_time
			push.data[:alert].should match(old_time_str)
		end
		end
	end	

	describe '#member_event_created' do
		it 'should send some push notifications' do
			Event.should_receive(:find).with(@event_id)
			@pusher.should_receive(:push).with({
				devices: @user.pushable_mobile_devices,
				alert: kind_of(String),
				button: "View Event",
				extra: {
					"obj_type" => "event",
					"obj_id" => @event_id,
					"verb" => "created"
				}})

			@pusher.member_event_created(@user.id, @tenant_id, event_id: @event_id )
		end
	end	

	describe '#member_event_activated' do
		it 'should send some push notifications' do
			Event.should_receive(:find).with(@event_id)
			@pusher.should_receive(:push).with({
				devices: @user.pushable_mobile_devices,
				alert: kind_of(String),
				button: "View Event",
				extra: {
					"obj_type" => "event",
					"obj_id" => @event_id,
					"verb" => "activated"
				}})

			@pusher.member_event_activated(@user.id, @tenant_id, event_id: @event_id )
		end
	end	

	describe '#member_event_cancelled' do
		it 'should send some push notifications' do
			Event.should_receive(:find).with(@event_id)
			@pusher.should_receive(:push).with({
				devices: @user.pushable_mobile_devices,
				alert: kind_of(String),
				button: "View Event",
				extra: {
					"obj_type" => "event",
					"obj_id" => @event_id,
					"verb" => "cancelled"
				}})

			@pusher.member_event_cancelled(@user.id, @tenant_id, event_id: @event_id )
		end
	end	

	describe '#member_event_updated' do
		it 'should send some push notifications' do
			Event.should_receive(:find).with(@event_id)
			@pusher.should_receive(:push).with({
				devices: @user.pushable_mobile_devices,
				alert: kind_of(String),
				button: "View Event",
				extra: {
					"obj_type" => "event",
					"obj_id" => @event_id,
					"verb" => "updated"
				}})

			@pusher.member_event_updated(@user.id, @tenant_id, event_id: @event_id )
		end
	end	

	describe '#member_event_invite_reminder' do
		it 'should send some push notifications' do
			Event.should_receive(:find).with(@event_id)
			@pusher.should_receive(:push).with({
				devices: @user.pushable_mobile_devices,
				alert: kind_of(String),
				button: "View Event",
				extra: {
					"obj_type" => "event",
					"obj_id" => @event_id,
					"verb" => "reminder"
				}})

			@pusher.player_or_parent_event_invite_reminder(@user.id, @tenant_id, event_id: @event_id )
		end
	end	
end