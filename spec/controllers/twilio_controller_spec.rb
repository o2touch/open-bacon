require 'spec_helper'

describe TwilioController, type: :controller do 
	describe '#that sms receiving fucker' do
		before :each do
			@user = FactoryGirl.create :user, mobile_number: "+123456789"
		end
		it 'fucks them off if we do not know who they are' do
			post :sms_reply, From: "+2398749283", Body: "Y1"
			response.body.should match("<Sms>Sorry, we couldn't process your response</Sms>")
		end
		it 'fucks them off if they send use bullshit' do
			post :sms_reply, From: "+123456789", Body: "DICKHEADS!!!!1! ZOMG!"
			response.body.should match("<Sms>Unfortuantely that was an invalid response! Please try again.</Sms>")
		end
		it 'fucks them off if they send us an invalid code' do
			post :sms_reply, From: "+123456789", Body: "NFUCK ALL YOU DICKHEADS!!!!1! ZOMG!"
			response.body.should match("<Sms>Sorry, something went wrong and we were unable to process your message.</Sms>")
		end

		context 'valid shit' do
			before :each do
				@team = FactoryGirl.create :team, :with_events, event_count: 1
				TeamUsersService.add_player(@team, @user, false, nil, false)
			end
			it 'responds appropriately if a parent is responding for their child' do
				@other_user = FactoryGirl.create :user, mobile_number: "+987654321"
				SmsSent.create({
					sms_reply_code: 1,
					user_id: @other_user.id,
					teamsheet_entry_id: TeamsheetEntry.find_by_event_and_user(@team.events.first, @user).id
				})

				post :sms_reply, From: "+987654321", Body: "Y1"
				response.body.should match("<Sms>Thanks #{@other_user.name.titleize}. We've put #{@user.name.titleize} down as available.</Sms>")
			end
			it 'responds appropriately if its just your regular old player responding' do
				SmsSent.create({
					sms_reply_code: 1,
					user_id: @user.id,
					teamsheet_entry_id: TeamsheetEntry.find_by_event_and_user(@team.events.first, @user).id
				})

				post :sms_reply, From: "+123456789", Body: "Y1"
				response.body.should match("<Sms>Thanks #{@user.name.titleize}. We've put you down as available.</Sms>")
			end
		end
	end	
end