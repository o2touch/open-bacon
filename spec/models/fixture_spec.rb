require 'spec_helper'

describe Fixture do
	describe 'validations' do
		before :each do
			@fixture = FactoryGirl.build :fixture
		end

		it 'is valid when its valid' do
			@fixture.should be_valid
		end
		it 'requires a title < 70 chars' do
			@fixture.title = "long long long long long long long long long long long long long long long long title"
			@fixture.should_not be_valid
		end
		it 'requires a status in EventStatusEnum' do
			@fixture.status = -1
			@fixture.should_not be_valid
		end
		it 'requires a time_zone if there is a time' do
			@fixture.time_zone = nil
			@fixture.should_not be_valid
		end
		it 'does not allow a home event without a home team' do
			@fixture.home_event = FactoryGirl.build :event
			@fixture.should_not be_valid
		end
		it 'does not allow an away event with an away team' do
			@fixture.away_event = FactoryGirl.build :event
			@fixture.should_not be_valid
		end
		it 'requires home_event.team == home_team' do
			@fixture.home_team = FactoryGirl.build :team
			TeamDSService.add_team(@fixture.division_season, @fixture.home_team)
			#@fixture.division.teams << @fixture.home_team
			@fixture.home_event = FactoryGirl.build :event
			@fixture.should_not be_valid
		end
		it 'requires away_event.team == away_team' do
			@fixture.away_team = FactoryGirl.build :team 
			#@fixture.division.teams << @fixture.away_team
			TeamDSService.add_team(@fixture.division_season, @fixture.away_team)
			@fixture.away_event = FactoryGirl.build :event
			@fixture.should_not be_valid
		end
		it 'requires home team to be in the division' do
			@fixture.home_team = FactoryGirl.build :team 
			@fixture.should_not be_valid
		end
		it 'requires away team to be in the division' do
			@fixture.away_team = FactoryGirl.build :team 
			@fixture.should_not be_valid
		end
	end

	describe 'methods' do
		describe '#is_deletable?' do
			before :each do
				@fixture = FactoryGirl.build :fixture
			end
			it 'is deletable if there are no events' do
				@fixture.is_deletable?.should be_true
			end
			it 'is not deletable if there is a home_event' do
				@fixture.home_event = FactoryGirl.build :event
				@fixture.is_deletable?.should be_false
			end
			it 'is not deletable if there is a away_event' do
				@fixture.away_event = FactoryGirl.build :event
				@fixture.is_deletable?.should be_false
			end
		end

		describe '#trash_dependents' do
			before :each do
				@fixture = FactoryGirl.build :fixture
			end
			it 'should call destroy on home_event if present' do
				@he = double
				@fixture.stub(home_event: @he)
				@he.should_receive(:destroy)
				@fixture.trash_dependents
			end
			it 'should not call destroy on home_event if present' do
				@fixture.stub(home_event: nil)
				# no test, but non-desired behaviour would result in error.
				@fixture.trash_dependents
			end
			it 'should call destroy on away_event if present' do
				@ae = double
				@fixture.stub(away_event: @ae)
				@ae.should_receive(:destroy)
				@fixture.trash_dependents
			end
			it 'should not call destroy on home_event if present' do
				@fixture.stub(home_event: nil)
				# no test, but non-desired behaviour would result in error.
				@fixture.trash_dependents
			end
			it 'should trash result if present' do
				@r = double
				@r.stub(is_special?: false)
				@fixture.stub(result: @r)
				@r.should_receive(:trash!)
				@fixture.trash_dependents
			end
			it 'should not trash result if not present' do
				@fixture.stub(result: nil)
				# no test, but non-desired behaviour would result in error.
				@fixture.trash_dependents
			end
			it 'should not trash result if special_result' do
				@r = double(is_special?: true)
				@fixture.stub(result: @r)
				@r.should_not_receive(:trash!)
				@fixture.trash_dependents
			end
			it 'should trash points if present' do
				@p = double
				@fixture.stub(points: @p)
				@p.should_receive(:trash!)
				@fixture.trash_dependents
			end
			it 'should not trash point if not present' do
				@fixture.stub(points: nil)
				# no test, but non-desired behaviour would result in error.
				@fixture.trash_dependents
			end
		end
	end

	describe 'callback edit_mode ting' do
		context 'creating a fixture' do
			before :each do
				@fixture = FactoryGirl.build :fixture
				@fixture.home_team = FactoryGirl.create :team
				@fixture.away_team = FactoryGirl.create :team
				@fixture.division_season = FactoryGirl.create(:division_season)
				TeamDSService.add_team(@fixture.division_season, @fixture.home_team)
				TeamDSService.add_team(@fixture.division_season, @fixture.away_team)
			end

			context 'during create' do
				it 'throws if the home_event is not nil' do
					@fixture.home_event = FactoryGirl.create :event, team: @fixture.home_team
					expect { @fixture.save }.to raise_error
				end
				it 'throws if the away_event is not nil' do
					@fixture.away_event = FactoryGirl.create :event, team: @fixture.away_team
					expect { @fixture.save }.to raise_error
				end
				it 'throws if the status is DELETED' do
					@fixture.status = EventStatusEnum::DELETED
					expect { @fixture.save }.to raise_error
				end
			end

			context 'after created' do
				before :each do
					@allowed = %w(id division_id division_season_id created_at updated_at edited edits)

					@fixture = FactoryGirl.build :fixture
					@fixture.home_team = FactoryGirl.create :team
					@fixture.away_team = FactoryGirl.create :team
					@fixture.division_season = FactoryGirl.create(:division_season)
					TeamDSService.add_team(@fixture.division_season, @fixture.home_team)
					TeamDSService.add_team(@fixture.division_season, @fixture.away_team)
					@old_attrs = @fixture.attributes
					@fixture.save
				end
				it 'only has division and meta type shit set' do
					@fixture.attributes.each do |k, v|
						next if @allowed.include? k
						v.should be_nil
					end
				end
				it 'has edited set to true' do
					@fixture.edited.should eq(true)
				end
				it 'has all attribute values in the edits hash' do
					@fixture.edits.each do |k, v|
						next if @allowed.include? k
						@old_attrs[k].should eq(v)
					end	
				end
			end
		end

		context 'updating a fixture' do
			before :each do
				EventInvitesService.stub(:add_players)
				@fixture = FactoryGirl.build :fixture
				@fixture.home_team = FactoryGirl.create :team
				@fixture.away_team = FactoryGirl.create :team
				@fixture.division_season = FactoryGirl.create(:division_season)
				TeamDSService.add_team(@fixture.division_season, @fixture.home_team)
				TeamDSService.add_team(@fixture.division_season, @fixture.away_team)
				@fixture.location = FactoryGirl.create :location
				@fixture.publish_edits!
			end
			it 'throws if home_event_id has changed' do
				@fixture.home_event = FactoryGirl.create :event, team_id: @fixture.home_team_id
				expect { @fixture.save }.to raise_error
			end
			it 'throws if away_event_id has changed' do
				@fixture.away_event = FactoryGirl.create :event, team_id: @fixture.away_team_id
				expect { @fixture.save }.to raise_error
			end
			it 'throws if home_team_id has changed' do
				team = FactoryGirl.create :team
				TeamDSService.add_team(@fixture.division_season, team)
				@fixture.home_event.team_id = team.id
				@fixture.home_team = team
				expect { @fixture.save }.to raise_error
			end
			it 'throws if away_team_id has changed' do
				team = FactoryGirl.create :team
				TeamDSService.add_team(@fixture.division_season, team)
				@fixture.away_event.team_id = team.id
				@fixture.away_team = team
				expect { @fixture.save }.to raise_error
			end
			it 'throws if status is set to deleted, but fixture is not deletable' do
				@fixture.status = EventStatusEnum::DELETED
				expect { @fixture.save }.to raise_error
			end
			it 'leaves all attrs (that teams see) how they were' do
				loc = @fixture.location
				title = @fixture.title
				time = @fixture.time

				@fixture.location = FactoryGirl.create(:location)
				@fixture.title = "new title FTW"
				@fixture.time = 100.years.from_now
				@fixture.save!

				@fixture.location.should eq(loc)
				@fixture.title.should eq(title)
				@fixture.time.should eq(time)
			end
			it 'puts all updates in the edits hash' do
				loc = FactoryGirl.create :location
				title = "new title FTW"
				time = 100.years.from_now

				@fixture.title = title
				@fixture.time = time
				@fixture.location = loc
				@fixture.save!

				@fixture.edits["location_id"].should eq(loc.id)
				@fixture.edits["title"].should eq(title)
				@fixture.edits["time"].should eq(time)
			end
			it 'sets edited to true' do
				@fixture.title = "new title FTW"
				@fixture.save!
				@fixture.edited.should be_true
			end
			# for when you change something and, then change it back again...
			it 'does not leave old edits in the edits hash' do
				@fixture.update_attributes!({ status: 1})
				@fixture.update_attributes!({ status: 0})
				@fixture.edits.keys.should_not include("status")
			end
		end

		context 'livening the changes' do
			before :each do
				# stub this one, so the event gets added to the team, but
				# not all the other shit
				EventInvitesService.stub(:add_players)
				@fixture = FactoryGirl.build :fixture
				@fixture.home_team = FactoryGirl.create :team
				@fixture.away_team = FactoryGirl.create :team
				@fixture.division_season = FactoryGirl.create(:division_season)
				TeamDSService.add_team(@fixture.division_season, @fixture.home_team)
				TeamDSService.add_team(@fixture.division_season, @fixture.away_team)
				
				# TODO: TS Look into a better way of doing this - PR
				# Need to specifically set this because of problem with failing test (due to FactoryGirl?)
				location = FactoryGirl.create(:location)
				@fixture.location_id = location.id

				@fixture.save
			end	

			it 'updates fixtures attrs according to the edits hash' do
				@title
				@time = 1.day.from_now
				edits = { "title" => @title, "time" => @time, "time_zone" => "Europe/London", "status" => 1, "time_tbc" => false}

				@fixture.edits = edits
				@fixture.edited = true
				@fixture.publish_edits!

				@fixture.title.should eq(@title)
				@fixture.time.should eq(@time)
			end

			it 'sets edited to false' do
				@fixture.publish_edits!
				@fixture.edited.should eq(false)
			end

			it 'empties the edits hash' do
				@fixture.publish_edits!
				@fixture.edits.should eq({})
			end

			it 'notifys the teams of the changes to cancelled'

			it 'updates the events when the fixture gets changes (eg. cancelled)' do
				@fixture.publish_edits!
				@fixture.update_attribute(:status, EventStatusEnum::CANCELLED)
				@fixture.publish_edits!
				@fixture.reload

				@fixture.home_event.status.should eq(EventStatusEnum::CANCELLED)
				@fixture.away_event.status.should eq(EventStatusEnum::CANCELLED)
			end	

			it 'creates a events if !xxx_team.nil? && xxx_event.nil?' do
				TeamEventsService.should_receive(:add).twice.and_call_original
				lambda{ @fixture.publish_edits! }.should change(Event, :count).by(2)
			end

			it 'does not update the event (last_edited) if there are no changes' do
				
				@fixture.publish_edits!
				
				home_edited = @fixture.home_event.last_edited
				@fixture.reload
				
				sleep 10				
				@fixture.publish_edits!
				(home_edited - @fixture.home_event.last_edited).should eq(0)
			end
		end

		context 'updating a fixture with manual_override! enabled' do
			before :each do
				EventInvitesService.stub(:add_players)
				@fixture = FactoryGirl.build :fixture
				@fixture.home_team = FactoryGirl.create :team
				@fixture.away_team = FactoryGirl.create :team
				@fixture.division_season = FactoryGirl.create(:division_season)
				TeamDSService.add_team(@fixture.division_season, @fixture.home_team)
				TeamDSService.add_team(@fixture.division_season, @fixture.away_team)
				@fixture.location = FactoryGirl.create :location
				@fixture.publish_edits!
				@fixture.manual_override!
			end
			it 'does not throw if home_event_id has changed' do
				@fixture.home_event = FactoryGirl.create :event, team_id: @fixture.home_team_id
				expect { @fixture.save }.not_to raise_error
			end
			it 'does not throw if away_event_id has changed' do
				@fixture.away_event = FactoryGirl.create :event, team_id: @fixture.away_team_id
				expect { @fixture.save }.not_to raise_error
			end
			it 'does not throw if home_team_id has changed' do
				team = FactoryGirl.create :team
				@fixture.home_event.team_id = team.id
				@fixture.home_team = team
				expect { @fixture.save }.not_to raise_error
			end
			it 'does not throw if away_team_id has changed' do
				team = FactoryGirl.create :team
				@fixture.away_event.team_id = team.id
				@fixture.away_team = team
				expect { @fixture.save }.not_to raise_error
			end
		end
	end
end

