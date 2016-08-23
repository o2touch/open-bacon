require 'spec_helper'
require 'sidekiq/testing'

describe Ns2::Processors::UsersProcessor do
	let(:team){ FactoryGirl.create :team, :with_events, event_count: 2 }
	let(:follower){ FactoryGirl.create :user }
	let(:player){ FactoryGirl.create :user }

	before :each do
		@mail = double(deliver: "cool")
	end

	describe '#created' do
		describe '# follower role' do
			it 'should send two lovely emails' do
				TeamRoleMailer.should_receive(:follower_created).once do |recipient_id, tenant_id, data|
					recipient_id.should eq(follower.id)
					data[:team_id].should eq(team.id)
				end.and_return(@mail)

				# commented as code commented. TS
				# TeamMailer.should_receive(:follower_schedule_created).once do |recipient_id, data|
				# 	recipient_id.should eq(follower.id)
				# 	data[:team_id].should eq(team.id)
				# 	data[:event_ids].should eq(team.events.map{|e| e.id})
				# end.and_return(@mail)

				role = PolyRole.create!(user: follower, obj: team, role_id: PolyRole::FOLLOWER)

				ae = AppEvent.create!(obj: role, subj: follower, verb: "created", meta_data: {})
				Ns2::Processors::TeamRolesProcessor.process(ae)
				Ns2NotificationItemWorker.jobs.size.should eq(1)
				Ns2NotificationItemWorker.drain
			end
		end

		describe 'o2 touch user role' do
			it 'should send two lovely emails' do
				role = PolyRole.create!(user: player, obj: team, role_id: PolyRole::PLAYER)

				TeamRoleMailer.should_receive(:player_o2_touch_player_role_created).once do |recipient_id, tenant_id, data|
					recipient_id.should eq(player.id)
					data[:team_id].should eq(team.id)
				end.and_return(@mail)
				TeamRoleMailer.should_receive(:organiser_o2_touch_player_role_created).once do |recipient_id, tenant_id, data|
					recipient_id.should eq(team.organisers.last.id)
					data[:team_id].should eq(team.id)
					data[:player_id].should eq(player.id)
				end.and_return(@mail)

				ae = AppEvent.create!(obj: role, subj: player, verb: "created", meta_data: {})
				Ns2::Processors::TeamRolesProcessor.process(ae)
				Ns2NotificationItemWorker.jobs.size.should eq(2)
				Ns2NotificationItemWorker.drain
			end
		end
	end
end