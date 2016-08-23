require 'spec_helper'

describe IncomingMailHelper do
	before :each do
		@user = double("user")
		@ai = double("ai")
	end

	describe 'encode_reply_to' do
		it 'should error if user is nil' do
			expect { encode_reply_to(nil, @ai) }.to raise_error
		end
		it 'should error if ai is nil' do
			expect { encode_reply_to(@user, nil) }.to raise_error
		end
		it 'should error if user has no incoming_email_token' do
			@user.stub!(incoming_email_token: nil)
			expect { encode_reply_to(@user, @ai) }.to raise_error
		end
		it 'should return the correct reply-to address' do
			version = "1"
			model = "ai"
			model_id = 1234
			user_token = "u342yeihdfksdnfa"
			incoming_mail_domain = INCOMING_MAIL_DOMAIN
			@user.stub!(incoming_email_token: user_token)
			@ai.stub!(id: model_id)


			address = "#{version}_#{user_token}_#{model}_#{model_id}@#{incoming_mail_domain}"
			encode_reply_to(@user, @ai).should eq(address)
		end
	end

	describe 'decode_reply_to' do
		it 'should return nil if address is nil' do
			decode_reply_to(nil).should eq(nil)
		end
		it 'should return nil if the address is incorrect' do
			decode_reply_to("notanaddress").should eq(nil)
		end
		it 'should return an ai and user if all is swell' do
			address = "1_token_ai_1234@mail.mitoo.co"

			@user = double("user")
			@ai = double("ai")
			User.should_receive(:find_by_incoming_email_token).with("token").and_return(@user)
			ActivityItem.should_receive(:find_by_id).with(1234).and_return(@ai)

			d_user, d_ai = decode_reply_to(address)
			d_user.should eq(@user)
			d_ai.should eq(@ai)
		end
	end

	describe 'encode_message_id' do
		it 'should error if user is nil' do
			expect { encode_message_id(nil, @ai) }.to raise_error
		end
		it 'should error if ai is nil' do
			expect { encode_message_id(@user, nil) }.to raise_error
		end
		it 'should return the correct message-id' do
			time = Time.now
			id = 123
			version = 1

			@user = double(id: id)
			@model = double("model")
			@model.stub!(created_at: time)
			@model.stub!(is_a?: true)
			@model.stub!(id: id)

			# <[VERSION].[MODEL_TYPE].[MODEL_CREATED_AT.to_i].[MODEL_ID].[SENT_TO_ID]@mitoo.co>
			message_id = "<#{version}.ir.#{time.to_i}.#{id}.#{id}@mitoo.co>"
			encode_message_id(@user, @model).should eq(message_id)
		end
	end
end