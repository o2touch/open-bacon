require 'spec_helper'

describe NotificationProcessorUtil do
  context 'returns future events attending' do
    it "is valid" do
      user = FactoryGirl.create(:user, :with_teams, :team_count => 1 )
      team = user.teams_as_organiser.first
      
      eventA = FactoryGirl.create(:event, :user => user, :team => team)
      eventB = FactoryGirl.create(:event, :user => user, :team => team)
      eventC = FactoryGirl.create(:event, :user => user, :team => team)

      random_user = FactoryGirl.create(:user)

      tseA = FactoryGirl.create(:teamsheet_entry, :event => eventA, :user => user)
      TeamsheetEntriesService.set_availability(tseA, AvailabilityEnum::AVAILABLE, user)

      tseB = FactoryGirl.create(:teamsheet_entry, :event => eventA, :user => random_user)
      TeamsheetEntriesService.set_availability(tseB, AvailabilityEnum::AVAILABLE, random_user)

      tseC = FactoryGirl.create(:teamsheet_entry, :event => eventB, :user => user)
      TeamsheetEntriesService.set_availability(tseC, AvailabilityEnum::UNAVAILABLE, user)

      tseD = FactoryGirl.create(:teamsheet_entry, :event => eventB, :user => random_user)
      TeamsheetEntriesService.set_availability(tseD, AvailabilityEnum::AVAILABLE, random_user)
          
      eventA.teamsheet_entries = [tseA, tseB]
      eventA.save

      eventB.teamsheet_entries = [tseC, tseD]
      eventB.save

      events = [eventA, eventB, eventC]

      events_attending = NotificationProcessorUtil.get_future_events_attending(events, user).map(&:id)
      events_attending.should == [eventA.id]      

      events_attending = NotificationProcessorUtil.get_future_events_attending(events, random_user).map(&:id)
      events_attending.should == [eventA.id, eventB.id]      
    end

    it 'another scenario' do
      user = FactoryGirl.create(:user, :with_teams, :team_count => 1)
      team = user.teams_as_organiser.first
      
      eventA = FactoryGirl.create(:event, :user => user, :team => team)
      eventB = FactoryGirl.create(:event, :user => user, :team => team)
      eventC = FactoryGirl.create(:event, :user => user, :team => team)

      random_user = FactoryGirl.create(:user)

      tseA = FactoryGirl.create(:teamsheet_entry, :event => eventA, :user => user)
      TeamsheetEntriesService.set_availability(tseA, AvailabilityEnum::AVAILABLE, user)

      tseB = FactoryGirl.create(:teamsheet_entry, :event => eventA, :user => random_user)
      TeamsheetEntriesService.set_availability(tseB, AvailabilityEnum::AVAILABLE, random_user)

      tseC = FactoryGirl.create(:teamsheet_entry, :event => eventB, :user => user)
      TeamsheetEntriesService.set_availability(tseC, AvailabilityEnum::AVAILABLE, user)

      tseD = FactoryGirl.create(:teamsheet_entry, :event => eventB, :user => random_user)
      TeamsheetEntriesService.set_availability(tseD, AvailabilityEnum::AVAILABLE, random_user)
          
      eventA.teamsheet_entries = [tseA, tseB]
      eventA.save

      eventB.teamsheet_entries = [tseC, tseD]
      eventB.save

      events = [eventA, eventB, eventC]

      events_attending = NotificationProcessorUtil.get_future_events_attending(events, user).map(&:id)
      events_attending.should == [eventA.id, eventB.id]      
    end
  end
end
