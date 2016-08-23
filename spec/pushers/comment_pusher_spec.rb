require 'spec_helper'

describe CommentPusher do
	before :each do
		@team = FactoryGirl.create :team
		@pusher = CommentPusher.new
		@user = FactoryGirl.create :user, :with_mobile_device
		@commenter = FactoryGirl.create :user
		@activity_item = 
		@message = @team.messages.create!({
			text: "FUCK OFF DICKHEADS",
			user: @original_poster
		})
		EventMessageHelper.new.create_activity_item(@message)
		@comment = @message.activity_item.create_comment(@commenter, "HI")
		@activity_item = @message.activity_item

		@data = {
			actor_id: @commenter.id,
			comment_id: @comment.id,
			activity_item_id: @activity_item.id
		}

	end

	describe '#comment_created' do
		it 'should send a sweet push' do
			@pusher.should_receive(:push).with({
				devices: @user.pushable_mobile_devices,
				alert: kind_of(String),
				button: kind_of(String),
				extra: {
					obj_type: "comment",
					obj_id: @comment.id,
					verb: "created",
					activity_item_id: @activity_item.id
				}			
			})
			@pusher.comment_created(@user.id, tenant_id=1, @data)
		end
	end
end