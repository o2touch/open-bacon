require 'spec_helper'

describe EventInvitesService do
	let(:organiser) { FactoryGirl.create(:user, :with_team_events, team_count: 1) }
	let(:junior) { FactoryGirl.create(:junior_user) }
	let(:parent) { junior.parents.first }
	let(:senior) { FactoryGirl.create(:user) }
	let(:event) { organiser.future_events.first }
	let(:team) { team = event.team }

	describe 'add players to an event' do
		before(:each) do
			team.add_parent(parent)

			@players = [parent, junior, senior, organiser]
			@players.each { |x| event.is_invited?(x).should be_false }
			@teamsheet_entries = EventInvitesService.add_players(event, @players)
		end

		context 'organisers, parents, seniors and juniors' do
			it 'returns a list of teamsheet entries' do
				@teamsheet_entries.count.should == [organiser, junior, senior].count
			end

			it 'does not invite parents to the event' do
				event.is_invited?(parent).should be_false
			end

			it 'invites juniors to the event' do
				event.is_invited?(junior).should be_true
			end

			it 'invites seniors to the event' do
				event.is_invited?(senior).should be_true
			end

			it 'invites organisers to the event' do
				event.is_invited?(organiser).should be_true
			end
		end
	end
end
