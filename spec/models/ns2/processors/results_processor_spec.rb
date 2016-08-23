require 'spec_helper'
require 'sidekiq/testing'

describe Ns2::Processors::ResultsProcessor do
	let(:home_team){ FactoryGirl.create :team, :with_players, player_count: 1 }
	let(:away_team){ FactoryGirl.create :team, :with_players, player_count: 1 }
	let(:other_team){ FactoryGirl.create :team, :with_players, player_count: 1 }
	let(:other_other_team){ FactoryGirl.create :team, :with_players, player_count: 1 }
	let(:division) do
		division = FactoryGirl.create :division_season
		TeamDSService.add_team(division, home_team)
		TeamDSService.add_team(division, away_team)
		TeamDSService.add_team(division, other_team)
		TeamDSService.add_team(division, other_other_team)
		division
	end
	let(:fixture) do
		f = FactoryGirl.create(:fixture, home_team: home_team, away_team: away_team, division_season: division)
		f.publish_edits!
		f
	end
	let(:result) do
		result = FactoryGirl.create(:soccer_result)
		result.fixture = fixture
		result.save
		result
	end
	let(:junior){ FactoryGirl.create(:junior_user) }
	let(:follower){ FactoryGirl.create(:user) }
	let(:user){ FactoryGirl.create :user }

	before :each do
		@mail = double(deliver: "ahsfsakd")
	end

	describe '#created' do
		# sets ups a team with 1 org, 1 player, 1 junior player, 1 parent
		#  and one with 1 org, 1 player, 1 follower,
		#  and another in the same division with 1 org, 1 player and 1 follower.
		#  All except junior should get one email.
		it 'sends some emails' do
			ResultMailer.should_receive(:organiser_result_created).twice do |recipient_id, tenant_id, data|
				u = User.find(recipient_id)
				t = Team.find(data[:team_id])
				(t == fixture.home_team || t == fixture.away_team).should be_true
				t.has_organiser?(u).should be_true
			end.and_return(@mail)

			ResultMailer.should_receive(:player_result_created).twice do |recipient_id, tenant_id, data|
				u = User.find(recipient_id)
				t = Team.find(data[:team_id])
				(t == fixture.home_team || t == fixture.away_team).should be_true
				t.has_player?(u).should be_true
			end.and_return(@mail)

			ResultMailer.should_receive(:parent_result_created).once do |recipient_id, tenant_id, data|
				u = User.find(recipient_id)
				u.id.should eq(junior.parents.first.id)
				t = Team.find(data[:team_id])
				t.id.should eq(away_team.id)
				(t == fixture.home_team || t == fixture.away_team).should be_true
				t.has_parent?(u).should be_true
			end.and_return(@mail)

			ResultMailer.should_receive(:follower_result_created).once do |recipient_id, tenant_id, data|
				u = User.find(recipient_id)
				u.id.should eq(follower.id)
				t = Team.find(data[:team_id])
				e = Event.find(data[:event_id])
				e.team.should eq(t)
				t.id.should eq(home_team.id)
				(t == fixture.home_team || t == fixture.away_team).should be_true
				t.has_follower?(u).should be_true
			end.and_return(@mail)

			ResultMailer.should_receive(:organiser_division_result_created).twice do |recipient_id, tenant_id, data|
				u = User.find(recipient_id)
				t = Team.find(data[:team_id])
				data[:event_id].should be_nil
				t.has_organiser?(u).should be_true
			end.and_return(@mail)

			ResultMailer.should_receive(:player_division_result_created).twice do |recipient_id, tenant_id, data|
				u = User.find(recipient_id)
				t = Team.find(data[:team_id])
				data[:event_id].should be_nil
				t.has_player?(u).should be_true
			end.and_return(@mail)

			ResultMailer.should_receive(:follower_division_result_created).once do |recipient_id, tenant_id, data|
				u = User.find(recipient_id)
				t = Team.find(data[:team_id])
				data[:event_id].should be_nil
				t.should eq(other_team)
				t.has_follower?(u).should be_true
			end.and_return(@mail)

			home_team.add_follower(follower)
			away_team.add_player(junior)
			away_team.add_parent(junior.parents.first)
			other_team.add_follower(follower)

			ae = AppEvent.create!(obj: result, subj: user, verb: "created", meta_data: {})
			Ns2::Processors::ResultsProcessor.process(ae)
			#Ns2NotificationItemWorker.jobs.size.should eq(9)
			Ns2NotificationItemWorker.drain
		end
	end


	# we don't send this shit no more. TS
	# describe '#updated' do
	# 	it 'sends some emails' do
	# 		ResultMailer.should_receive(:organiser_result_updated).twice do |recipient_id, data|
	# 			u = User.find(recipient_id)
	# 			t = Team.find(data[:team_id])
	# 			(t == fixture.home_team || t == fixture.away_team).should be_true
	# 			t.has_organiser?(u).should be_true
	# 		end.and_return(@mail)

	# 		ResultMailer.should_receive(:player_result_updated).twice do |recipient_id, data|
	# 			u = User.find(recipient_id)
	# 			t = Team.find(data[:team_id])
	# 			(t == fixture.home_team || t == fixture.away_team).should be_true
	# 			t.has_player?(u).should be_true
	# 		end.and_return(@mail)

	# 		ResultMailer.should_receive(:parent_result_updated).once do |recipient_id, data|
	# 			u = User.find(recipient_id)
	# 			u.id.should eq(junior.parents.first.id)
	# 			t = Team.find(data[:team_id])
	# 			t.id.should eq(away_team.id)
	# 			(t == fixture.home_team || t == fixture.away_team).should be_true
	# 			t.has_parent?(u).should be_true
	# 		end.and_return(@mail)

	# 		ResultMailer.should_receive(:follower_result_updated).once do |recipient_id, data|
	# 			u = User.find(recipient_id)
	# 			u.id.should eq(follower.id)
	# 			t = Team.find(data[:team_id])
	# 			t.id.should eq(home_team.id)
	# 			(t == fixture.home_team || t == fixture.away_team).should be_true
	# 			t.has_follower?(u).should be_true
	# 		end.and_return(@mail)

	# 		home_team.add_follower(follower)
	# 		away_team.add_player(junior)
	# 		away_team.add_parent(junior.parents.first)

	# 		ae = AppEvent.create!(obj: result, subj: user, verb: "updated", meta_data: {})
	# 		Ns2::Processors::ResultsProcessor.process(ae)
	# 		Ns2NotificationItemWorker.jobs.size.should eq(6)
	# 		Ns2NotificationItemWorker.drain
	# 	end
	# end
end