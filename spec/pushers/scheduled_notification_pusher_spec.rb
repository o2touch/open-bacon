require 'spec_helper'

describe ScheduledNotificationPusher do
	before :each do
		@pusher = ScheduledNotificationPusher.new
		@user = FactoryGirl.create :user, :with_mobile_device
		@event = FactoryGirl.create :event, team_id: 10
		@junior = FactoryGirl.create :junior_user
		@tenant_id = 1
	end	
	
	describe '#user_weekly_event_schedule' do
		it 'should send a push notification' do
			@data = {
				event_ids: [@event.id, 234, 5432, 233]
			}

			@pusher.should_receive(:push).with({
				devices: @user.pushable_mobile_devices,
				alert: "You have 4 events coming up this week. View more in the schedule",
				button: "View Schedule",
				extra: {
					obj_type: "team",
					obj_id: @event.team_id,
					verb: "schedule_created",
				}
			})

			@pusher.user_weekly_event_schedule(@user.id, @tenant_id, @data)
		end

		it 'does not send if no events' do
			@data = { event_ids: [] }	
			@pusher.should_not_receive(:push)
			@pusher.user_weekly_event_schedule(@user.id, @tenant_id, @data)
		end
	end

	# No longer used
	#
	# describe '#parent_weekly_event_schedule' do
	# 	it 'should send a push notification' do
	# 		name = @junior.first_name.titleize

	# 		@data = {
	# 			junior_id: @junior.id,
	# 			event_ids: [@event.id]
	# 		}

	# 		@pusher.should_receive(:push).with({
	# 			devices: @user.pushable_mobile_devices,
	# 			alert: "#{name} has 1 event coming up this week. View more in the schedule",
	# 			button: "View Schedule",
	# 			extra: {
	# 				obj_type: "team",
	# 				obj_id: @event.team_id,
	# 				verb: "schedule_created",
	# 			}
	# 		})

	# 		@pusher.parent_weekly_event_schedule(@user.id, @tenant_id, @data)
	# 	end

	# 	it 'should not send if no events' do
	# 		@data = { event_ids: [], junoir_id: @junior.id }	
	# 		@pusher.should_not_receive(:push)
	# 		@pusher.user_weekly_event_schedule(@user.id, @tenant_id, @data)
	# 	end
	# end
end