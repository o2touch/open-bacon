require 'spec_helper'

describe TwilioService do

	describe "#send_download_link" do 
		
		it "should send message" do

			number = "+17024184963"
			message = "Install the Mitoo app by going to: http://127.0.0.1/install"

			TwilioService.should_receive(:send_sms).with(number, message)

			TwilioService.send_download_link(number)
		end

	end

	describe 'send_event_invitation' do
	end

	describe 'send_sms' do
	end
end