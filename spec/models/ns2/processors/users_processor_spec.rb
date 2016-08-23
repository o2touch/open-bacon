require 'spec_helper'
require 'sidekiq/testing'

describe Ns2::Processors::UsersProcessor do
	let(:team){ FactoryGirl.create :team, :with_events, event_count: 2 }
	let(:follower){ FactoryGirl.create :user }
	let(:follower_with_mobile){ FactoryGirl.create :user, :as_invited_no_email }

	before :each do
		@mail = double(deliver: "cool")
		@mock_team_invite = FactoryGirl.create :team_invite, :team => team
	end

	describe '#user_imported' do

		let(:inviter){ FactoryGirl.create :user }

		context 'user with team and email' do
			it 'should send a lovely email' do
				Ns2UserMailer.should_receive(:user_imported).once do |recipient_id, tenant_id, data|
					recipient_id.should eq(follower.id)
					data[:team_id].should eq(team.id)
				end.and_return(@mail)

				md = { team_id: team.id }
				ae = AppEvent.create!(obj: follower, subj: follower, verb: "user_imported", meta_data: md)
				Ns2::Processors::UsersProcessor.process(ae)
				Ns2NotificationItemWorker.jobs.size.should eq(1)
				Ns2NotificationItemWorker.drain
			end
		end

		context 'user with email' do
			it 'should send a lovely email' do
				Ns2UserMailer.should_receive(:user_imported_generic).once do |recipient_id, tenant_id, data|
					recipient_id.should eq(follower.id)
				end.and_return(@mail)

				md = { }
				ae = AppEvent.create!(obj: follower, subj: follower, verb: "user_imported", meta_data: md)
				Ns2::Processors::UsersProcessor.process(ae)
				Ns2NotificationItemWorker.jobs.size.should eq(1)
				Ns2NotificationItemWorker.drain
			end
		end
	end

	describe '#follower_registered' do
		it 'should send two lovely emails' do
			Ns2UserMailer.should_receive(:follower_registered).once do |recipient_id, tenant_id, data|
				recipient_id.should eq(follower.id)
				data[:team_id].should eq(team.id)
			end.and_return(@mail)

			# corresponding code commented. TS
			# ScheduledNotificationMailer.should_receive(:user_weekly_event_schedule).once do |recipient_id, tenant_id, data|
			# 	recipient_id.should eq(follower.id)
			# 	data[:team_id].should eq(team.id)
			# 	# TODO: This is a bad test... need events here, leaving for speed. TS
			# 	data[:event_ids].count.should eq(0)
			# 	data[:new_sign_up].should be_true
			# end.and_return(@mail)

			md = { team_id: team.id }
			ae = AppEvent.create!(obj: follower, subj: follower, verb: "follower_registered", meta_data: md)
			Ns2::Processors::UsersProcessor.process(ae)
			Ns2NotificationItemWorker.jobs.size.should eq(1)
			Ns2NotificationItemWorker.drain
		end
	end

	describe '#follower_invited' do

		let(:inviter){ FactoryGirl.create :user }

		context 'with email' do
			it 'should send a lovely email' do
				Ns2UserMailer.should_receive(:follower_invited).once do |recipient_id, tenant_id, data|
					recipient_id.should eq(follower.id)
					data[:team_id].should eq(team.id)
				end.and_return(@mail)

				md = { team_id: team.id }
				ae = AppEvent.create!(obj: follower, subj: follower, verb: "follower_invited", meta_data: md)
				Ns2::Processors::UsersProcessor.process(ae)
				Ns2NotificationItemWorker.jobs.size.should eq(1)
				Ns2NotificationItemWorker.drain
			end
		end

		context 'with mobile' do

			before :each do
				@sms = double("Sms")
			end

			it 'should send a text' do

				TeamUsersService.stub(:get_user_invite).and_return(@mock_team_invite)

				UserSmser.should_receive(:follower_invited).once do |recipient_id, tenant_id, data| 
					recipient_id.should eq(follower_with_mobile.id)
					data[:team_id].should eq(team.id)
					data[:team_invite_id].should eq(@mock_team_invite.id)
				end.and_return(@sms)

				@sms.should_receive(:deliver).and_return({status: true})

				md = { team_id: team.id }
				ae = AppEvent.create!(obj: follower_with_mobile, subj: follower_with_mobile, verb: "follower_invited", meta_data: md)
				Ns2::Processors::UsersProcessor.process(ae)
				Ns2SmsNotificationItemWorker.jobs.size.should eq(1)
				Ns2SmsNotificationItemWorker.drain
			end
		end
	end
end