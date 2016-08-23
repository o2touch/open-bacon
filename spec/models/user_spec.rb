# encoding: UTF-8
require 'spec_helper'

describe User do

  context 'user factory' do
    it "is valid" do
      user = FactoryGirl.create(:user)
      user.should be_valid
      user.profile.should be_valid
      user.roles.should have_exactly(1).items
      user.roles.first.name.should eql RoleEnum::REGISTERED 
      user.events.should be_empty
    end
  
    it "with_events is valid" do
      user = FactoryGirl.create(:user, :with_events, :event_count => 10)
      user.events.should have_exactly(10).items
      user.events_created.should have_exactly(10).items
      user.events_playing.should be_empty
    end

    it "with_teams is valid" do
      user = FactoryGirl.create(:user, :with_teams, :team_count => 5)
      user.teams.should have_exactly(5).items
      user.teams_as_player.should have_exactly(5).items
      user.teams_as_organiser.should have_exactly(5).items
    end

    it "with_team_events is valid" do
      user = FactoryGirl.create(:user, :with_team_events, :team_count => 5, :team_event_count => 1)
      user.teams.should have_exactly(5).items
      user.teams_as_player.should have_exactly(5).items
      user.teams_as_organiser.should have_exactly(5).items
      user.teams.each do |t|
        t.events.should have_exactly(1).items
      end
    end    
  end

  context 'construction' do
    it 'validates the email format' do
      expect { 
        user = FactoryGirl.create(:user, :email => "Bad EmailAddress")
      }.to raise_error
      expect { 
        user = FactoryGirl.create(:user, :email => "Bad@EmailAddress")
      }.to raise_error
      expect { 
        user = FactoryGirl.create(:user, :email => "Bad.Email@Address.")
      }.to raise_error
      expect { 
        user = FactoryGirl.create(:user, :email => "Bad.Email.@Address.Com")
      }.to raise_error
      expect { 
        user = FactoryGirl.create(:user, :email => "Bad.Email@.Address.Com")
      }.to raise_error
      expect { 
        user = FactoryGirl.create(:user, :email => "Bad.Email@.Address..Com")
      }.to raise_error

      user = FactoryGirl.create(:user, :email => "Good.Email@Address.Com")
      user.should be_valid
      user = FactoryGirl.create(:user, :email => "Good..Email@Address.Com")
      user.should be_valid
      user = FactoryGirl.create(:user, :email => "Good.Email@Address.+.Com")
      user.should be_valid
    end

    it 'prevents contact information being stored against the a junior user' do
      expect { 
        FactoryGirl.create(:junior_user, :email => nil, :mobile_number => "+0123456789")
      }.to raise_error

      expect { 
        FactoryGirl.create(:junior_user, :email => "Good.Email@Address.Com")
      }.to raise_error

      expect { 
        FactoryGirl.create(:junior_user, :email => "Good.Email@Address.Com", :mobile_number => "+0123456789")
      }.to raise_error
    end
  end  

  context 'formats number before validation' do
    it "doesnt format the number if the country isnt specified" do
      user = FactoryGirl.create(:user, :mobile_number => "0123456789", :country => nil)
      user.country.should == nil
      user.mobile_number.should == "0123456789"
    end

    it "returns nil if the mobile_number isnt specified" do
      user = FactoryGirl.create(:user, :mobile_number => nil, :country => "GB")
      user.country.should == "GB"
      user.mobile_number.should == nil
    end
  end

  context 'username validation' do
    before :each do
      @user = FactoryGirl.build :user
    end
    it 'does not allow white space' do
      @user.username = "tim tim"
      @user.should_not be_valid
    end
    it 'cannot start with a number' do
      @user.username = "1tim"
      @user.should_not be_valid
    end
    it 'converts it to lower case' do
      @user.username = "TIM"
      @user.save
      @user.reload
      @user.username.should eq("tim")
    end

    context 'mobile devices and shit, innit' do
      before :each do
        @user = FactoryGirl.build :user
      end
      it 'returns logged-in and active device' do
        @user.mobile_devices << FactoryGirl.build(:mobile_device)
        @user.mobile_devices << FactoryGirl.build(:mobile_device, logged_in: false)
        @user.mobile_devices << FactoryGirl.build(:mobile_device, active: false)

        @user.mobile_devices.size.should eq(3)
        @user.pushable_mobile_devices.size.should eq(1)
      end
      it 'returns only devices with the right app' do
        @user.mobile_devices << FactoryGirl.build(:mobile_device) # mobile_app_id = 1
        @user.mobile_devices << FactoryGirl.build(:mobile_device,  mobile_app_id: 2)

        @user.mobile_devices.size.should eq(2)
        @user.pushable_mobile_devices(LandLord.default_tenant).size.should eq(1)
      end
    end
  end

  context '.first_name' do
    it 'returns first name when two names' do
      user = FactoryGirl.build :user, :name => "Bob Evans"
      user.first_name.should == "Bob"
    end

    it 'returns first name when hyphenated first name' do
      user = FactoryGirl.build :user, :name => "Bob-John Evans"
      user.first_name.should == "Bob-John"
    end

    it 'returns first name when three names' do
      user = FactoryGirl.build :user, :name => "Bob John Evans"
      user.first_name.should == "Bob"
    end

    it 'returns first name when random russian name' do
      user = FactoryGirl.build :user, :name => "Илья Шамрай"
      user.first_name.should == "Илья"
    end

    it 'returns name when only one name' do
      user = FactoryGirl.build :user, :name => "Bob"
      user.first_name.should == "Bob"
    end

    it 'returns name when name is nil' do
      user = FactoryGirl.build :user
      user.name = nil
      user.first_name.should be_nil
    end
  end

  context 'cached_events' do
    context 'user who owns events but not playing any events or following any teams' do
      it 'should return follower events and events the user is attending or created' do
        team = FactoryGirl.create(:team, :with_events, :event_count => 2)
        user = team.founder
        team.events.each do |event|
          event.is_invited?(user).should be_false
        end

        user.cached_events.should == team.events
      end
    end
    
    context 'user who owns events but not playing any events and following one team' do
      it 'should return follower events and events the user is attending or created' do
        team = FactoryGirl.create(:team, :with_events, :event_count => 2)
        user = team.founder
        team.events.each do |event|
          event.is_invited?(user).should be_false
        end

        following_team = FactoryGirl.create(:team, :with_events, :event_count => 2)
        following_team.add_follower(user)

        user.cached_events.should == team.events | following_team.events
      end
    end

    context 'user who does not own events but playing events in one team and following one team' do
      it 'should return follower events and events the user is attending or created' do
        team = FactoryGirl.create(:team, :with_events, :event_count => 2)
        user = FactoryGirl.create(:user)
        team.add_player(user)

        team.events.each do |event|
          event.teamsheet_entries << FactoryGirl.create(:teamsheet_entry, :event => event, :user => user)
        end

        following_team = FactoryGirl.create(:team, :with_events, :event_count => 2)
        following_team.add_follower(user)

        user.cached_events.should == team.events | following_team.events
      end
    end

    context 'user who does not own events, is not playing events, is not following a team but is a player in a team' do
      it 'should return follower events and events the user is attending or created' do
        team = FactoryGirl.create(:team, :with_events, :event_count => 2)
        user = FactoryGirl.create(:user)
        team.add_player(user)
        
        user.cached_events.should be_empty
      end
    end

    context 'user who owns events, is playing events and is following one team' do
      it 'should return follower events and events the user is attending or created' do
        team = FactoryGirl.create(:team, :with_events, :event_count => 2)
        user = team.founder
        team.events.each do |event|
          event.teamsheet_entries << FactoryGirl.create(:teamsheet_entry, :event => event, :user => user)
        end

        following_team = FactoryGirl.create(:team, :with_events, :event_count => 2)
        following_team.add_follower(user)
        
        user.cached_events.should == team.events | following_team.events
      end
    end

    context 'user who owns events, is playing events and is following multiple teams' do
      it 'should return follower events and events the user is attending or created' do
        team = FactoryGirl.create(:team, :with_events, :event_count => 2)
        user = team.founder
        team.events.each do |event|
          event.teamsheet_entries << FactoryGirl.create(:teamsheet_entry, :event => event, :user => user)
        end

        following_team = FactoryGirl.create(:team, :with_events, :event_count => 2)
        following_team.add_follower(user)
        
        following_team_two = FactoryGirl.create(:team, :with_events, :event_count => 2)
        following_team_two.add_follower(user)

        user.cached_events.should == team.events | following_team.events | following_team_two.events
      end
    end
  end

  context 'teams' do
    before :each do
      @user = FactoryGirl.create(:user)
      PolyRole.roles.each do |role|
        team = FactoryGirl.create(:team)
        team.add_member role, @user
      end
    end

    it 'should return all teams no matter what the role' do
      @user.reload
      @user.teams.count.should eq(PolyRole.roles.count)
    end
  end
end
