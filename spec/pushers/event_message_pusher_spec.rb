require 'spec_helper'

describe EventMessagePusher do
	def setup_message(messageable)
		@pusher = EventMessagePusher.new
		@user = FactoryGirl.create :user, :with_mobile_device
		@event_message = FactoryGirl.create :event_message
		@event_message.stub(:messageable).and_return(messageable)
		EventMessage.should_receive(:find).with(@event_message.id).and_return(@event_message)

		@data = {
			event_message_id: @event_message.id,
			event_id: 1,
			team_id: 1,
			division_id: 1,
			actor_id: 1
		}
	end

	describe '#member_event_message_created' do
		it 'should send a push notification' do
			messageable = double("messageable")
			messageable.stub(:title).and_return('title')
			messageable.stub(:game_type_string).and_return("game")
			setup_message(messageable)

			@pusher.should_receive(:push).with({
				devices: @user.pushable_mobile_devices,
				alert: kind_of(String),
				button: "View Message",
				extra: {
					obj_type: "message",
					obj_id: 1,
					verb: "created",
					activity_item_id: @event_message.activity_item.id
				}
			})

			@pusher.member_event_message_created(@user.id, Tenant.first, @data)
		end
	end

	describe '#team_event_message_created' do
		it 'should send a push notification' do
			messageable = double("messageable")
			messageable.stub(:name).and_return('title')
			setup_message(messageable)

			@pusher.should_receive(:push).with({
				devices: @user.pushable_mobile_devices,
				alert: kind_of(String),
				button: "View Message",
				extra: {
					obj_type: "message",
					obj_id: 1,
					verb: "created",
					activity_item_id: @event_message.activity_item.id
				}
			})
			@pusher.member_team_message_created(@user.id, Tenant.first, @data)
		end
	end

	describe '#division_event_message_created' do
		it 'should send a push notification' do
			messageable = double("messageable")
			messageable.stub_chain(:league, :title).and_return('title')
			setup_message(messageable)

			@pusher.should_receive(:push).with({
				devices: @user.pushable_mobile_devices,
				alert: kind_of(String),
				button: "View Message",
				extra: {
					obj_type: "message",
					obj_id: 1,
					verb: "created",
					activity_item_id: @event_message.activity_item.id
				}
			})
			@pusher.member_division_message_created(@user.id, Tenant.first, @data)
		end
	end
end