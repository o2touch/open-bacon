require 'spec_helper'

describe Api::V1::Mail::MessagesController do
	render_views

	describe '#create' do
		def do_create(attrs)
			post :create, attrs
		end

		before :each do
			@from = 'some_one@gmail.org.uk'
			@comment = "hi guys let's play football and shit, innit"
			@message_id = "some_message-id_9283hirway8@bluefields.com"
 
			@attrs = {
				'sender' => @from,
				'recipient' => "some_address_ldksjf9sa8y@reply.bluefields.com",
				'stripped-text' => @comment,
				'Message-Id' => @message_id,
				'subject' => "Re: sweet message from bluefields",
				'Auto-Submitted' => 'no'
			}

			@user = double(email: @from)

			@aic = double("aic")
			@aic.stub(:send_notifications)
			@ai = mock_model(ActivityItem)
			@ai.stub!(obj: double(is_a?: true))
			@ai.stub!(create_comment: @aic)

			@ability = double(can?: true)
			Ability.stub!(new: @ability)

			controller.stub(:decode_reply_to).and_return([@user, @ai])
			controller.stub!(auth_mailgun: true)
			EventNotificationService.stub(:send_comment_from_email_failure)
		end

		it 'all works' do
			@ai.should_receive(:create_comment).with(@user, @comment).and_return(@aic)
			@aic.should_receive(:send_notifications)
			do_create @attrs
			response.status.should eq(200)
		end
		it 'should check the request is from mailgun' do
			controller.should_receive(:auth_mailgun)
			do_create @attrs
		end
		it 'should return 200 if the request is not from mailgun' do
			controller.stub!(auth_mailgun: false)
			do_create @attrs
			response.status.should eq(200)
		end
		it 'should return 406 if the reply address is invalid' do
			controller.stub!(:decode_reply_to).and_return(false)
			do_create @attrs
			response.status.should eq(406)
		end
		it 'should return 406 if the user from address is incorrect' do
			@attrs['sender'] = "a_different_email_address@bluefields.com"
			do_create @attrs
			response.status.should eq(406)
		end
		it 'should return 406 if the user does not have permissions' do
			@ability.stub!(can?: false)
			do_create @attrs
			response.status.should eq(406)
		end
		it 'should send an email if it returns 406' do
			EventNotificationService.should_receive(:send_comment_from_email_failure).with(@from, @message_id)
			@ability.stub!(can?: false)
			do_create @attrs
		end

		describe '#likey_auto_resposne' do
			it 'should return 406 if subject is "out of office"' do
				@attrs['subject'] = "out of office"
				do_create @attrs
				response.status.should eq(406)
			end
			it 'should return 406 if Auto-Submitted header != no' do
				@attrs['Auto-Submitted'] = "blates, mike"
				do_create @attrs
				response.status.should eq(406)
			end
		end
	end
end