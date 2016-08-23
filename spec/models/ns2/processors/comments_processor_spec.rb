require 'spec_helper'
require 'sidekiq/testing'

describe Ns2::Processors::CommentsProcessor do
	before :each do
		@team = FactoryGirl.create :team, :with_events, :with_players, event_count: 1, player_count: 2
		@old_commenter = @team.players.third
		@old_commenter.mobile_devices << FactoryGirl.create(:mobile_device)
		@commenter = @team.players.second
		@original_poster = @team.organisers.first

		@mail = double(deliver: "asfa")
		@push = double(deliver: [{},{ok: true}])
	end

	context 'message comment' do
		before :each do
			@message = @team.messages.create!({
				text: "FUCK OFF DICKHEADS",
				user: @original_poster
			})
			EventMessageHelper.new.create_activity_item(@message)
			@old_comment = @message.activity_item.create_comment(@old_commenter, "ADSFASDFA")

			@comment = @message.activity_item.create_comment(@commenter, "HI")
		end
		it 'sends some emails and shit' do
			#UserNotificationsPolicy.any_instance.should_receive(:should_notify?).at_least(2).times

			CommentMailer.should_receive(:message_comment_created) do |recipient_id, tenant_id, data|
				recipient_id.should eq(@original_poster.id)
				data[:feed_owner_type].should eq("Team")
				data[:feed_owner_id].should eq(@team.id)
				data[:actor_id].should eq(@commenter.id)
				data[:activity_item_id].should eq(@message.activity_item.id)
			end.and_return(@mail)
			CommentPusher.should_receive(:message_comment_created) do |recipient_id, tenant_id, data|
				recipient_id.should eq(@old_commenter.id)
				data[:feed_owner_type].should eq("Team")
				data[:feed_owner_id].should eq(@team.id)
				data[:actor_id].should eq(@commenter.id)
				data[:activity_item_id].should eq(@message.activity_item.id)
			end.and_return(@push)

			ae = AppEvent.create!(obj: @comment, subj: @commenter, verb: "created", meta_data: {})
			Ns2::Processors::CommentsProcessor.process(ae)
			Ns2NotificationItemWorker.jobs.size.should eq(2)
			Ns2NotificationItemWorker.drain
		end
	end

	context 'invite response comment' do
		before :each do
			EventInvitesService.add_players(@team.events.first, @team.players, false)

			tse = @team.events.first.teamsheet_entries.first
			@ir = TeamsheetEntriesService.set_availability(tse, 1)

			@old_comment = @ir.activity_items.first.create_comment(@old_commenter, "ADSFASDFA")

			@comment = @ir.activity_items.first.create_comment(@commenter, "HI")
		end
		it 'sends some emails and shit' do
			#UserNotificationsPolicy.any_instance.should_receive(:should_notify?).at_least(2).times

			CommentMailer.should_receive(:invite_response_comment_created) do |recipient_id, tenant_id, data|
				recipient_id.should eq(@original_poster.id)
				data[:feed_owner_type].should eq("Event")
				data[:feed_owner_id].should eq(@team.id)
				data[:actor_id].should eq(@commenter.id)
				data[:activity_item_id].should eq(@ir.activity_items.first.id)
			end.and_return(@mail)
			CommentPusher.should_receive(:invite_response_comment_created) do |recipient_id, tenant_id, data|
				recipient_id.should eq(@old_commenter.id)
				data[:feed_owner_type].should eq("Event")
				data[:feed_owner_id].should eq(@team.id)
				data[:actor_id].should eq(@commenter.id)
				data[:activity_item_id].should eq(@ir.activity_items.first.id)
			end.and_return(@push)

			ae = AppEvent.create!(obj: @comment, subj: @commenter, verb: "created", meta_data: {})
			Ns2::Processors::CommentsProcessor.process(ae)
			Ns2NotificationItemWorker.jobs.size.should eq(2)
			Ns2NotificationItemWorker.drain
		end
	end
end
