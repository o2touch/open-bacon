require 'spec_helper'
require 'sidekiq/testing'

describe Ns2::Processors::DivisionSeasonsProcessor do

	describe '#launched' do
		before :each do
			@div = FactoryGirl.create :division_season
			@league = @div.league
			@t1 = FactoryGirl.create :team, :with_players, :with_events, event_count: 2, player_count: 3
			@t2 = FactoryGirl.create :team, :with_players, :with_events, event_count: 2, player_count: 3
			TeamDSService.add_team(@div, @t1)
			TeamDSService.add_team(@div, @t2)

			@u = FactoryGirl.create :user

			@mail = double(deliver: "hiiii")
		end

		it 'sends fuck loads of emails' do
			DivisionSeasonMailer.should_receive(:player_division_launched).exactly(6).times do |recip, tenant_id, data|
				u = User.find(recip)
				u.teams_as_player.should include(Team.find(data[:team_id]))
				u.teams_as_organiser.count.should eq(0)
				data[:league_id].should eq(@league.id)
				data[:team_invite_id].should be_kind_of(Integer)
			end.and_return(@mail)

			DivisionSeasonMailer.should_receive(:organiser_division_launched).twice do |recip, tenant_id, data|
				u = User.find(recip)
				u.teams_as_organiser.should include(Team.find(data[:team_id]))
				u.teams_as_player.count.should eq(1)
				data[:league_id].should eq(@league.id)
				data[:team_invite_id].should be_kind_of(Integer)
			end.and_return(@mail)

			TeamMailer.should_receive(:player_schedule_created).with(3, 1, {team_id: 1, league_id: 1, event_ids: [1, 2], actor_id: 11, mailer: "TeamMailer"}).and_return(@mail)
			TeamMailer.should_receive(:player_schedule_created).with(4, 1, {team_id: 1, league_id: 1, event_ids: [1, 2], actor_id: 11, mailer: "TeamMailer"}).and_return(@mail)
			TeamMailer.should_receive(:player_schedule_created).with(5, 1, {team_id: 1, league_id: 1, event_ids: [1, 2], actor_id: 11, mailer: "TeamMailer"}).and_return(@mail)
			TeamMailer.should_receive(:player_schedule_created).with(6, 1, {team_id: 1, league_id: 1, event_ids: [1, 2], actor_id: 11, mailer: "TeamMailer"}).and_return(@mail)
			TeamMailer.should_receive(:player_schedule_created).with(7, 1, {team_id: 2, league_id: 1, event_ids: [3, 4], actor_id: 11, mailer: "TeamMailer"}).and_return(@mail)
			TeamMailer.should_receive(:player_schedule_created).with(8, 1, {team_id: 2, league_id: 1, event_ids: [3, 4], actor_id: 11, mailer: "TeamMailer"}).and_return(@mail)
			TeamMailer.should_receive(:player_schedule_created).with(9, 1, {team_id: 2, league_id: 1, event_ids: [3, 4], actor_id: 11, mailer: "TeamMailer"}).and_return(@mail)
			TeamMailer.should_receive(:player_schedule_created).with(10, 1, {team_id: 2, league_id: 1, event_ids: [3, 4], actor_id: 11, mailer: "TeamMailer"}).and_return(@mail)

			ae = AppEvent.create!(obj: @div, subj: @u, verb: "launched", meta_data: {})
			
			Ns2::Processors::DivisionSeasonsProcessor.process(ae)
			Ns2AppEventWorker.jobs.size.should eq(2)
			Ns2AppEventWorker.drain
			Ns2NotificationItemWorker.jobs.size.should eq(16)
			Ns2NotificationItemWorker.drain
		end
	end

	describe '#published' do
		before :each do
			@div = FactoryGirl.create :division_season
			@league = @div.league
			@t1 = FactoryGirl.create :team, :with_players, :with_events, event_count: 2, player_count: 3
			@t2 = FactoryGirl.create :team, :with_players, :with_events, event_count: 2, player_count: 3
			TeamDSService.add_team(@div, @t1)
			TeamDSService.add_team(@div, @t2)

			@u = FactoryGirl.create :user

			@mail = double(deliver: "hiiii")
		end

		it 'sends some nice emails' do
			AppEventService.should_receive(:create).exactly(2).times.and_call_original
			TeamMailer.should_receive(:player_schedule_updated).exactly(8).times do |recipient_id, tenant_id, data|
				u = User.find(recipient_id)
				t = Team.find(data[:team_id])
				u.teams.should include(t)
				data[:league_id].should eq(@league.id)
				data[:event_ids].should eq(t.events.map{|e| e.id})
			end.and_return(@mail)

			ae = AppEvent.create!(obj: @div, subj: @u, verb: "published", meta_data: {})

			Ns2::Processors::DivisionSeasonsProcessor.process(ae)
			Ns2AppEventWorker.jobs.size.should eq(2)
			Ns2AppEventWorker.drain
			Ns2NotificationItemWorker.jobs.size.should eq(8)
			Ns2NotificationItemWorker.drain
		end
	end
end