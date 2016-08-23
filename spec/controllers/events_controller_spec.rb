require 'spec_helper'

describe EventsController, :type => :controller  do

  describe '#index' do
    it 'does not error if the event has a location' do
      @event = FactoryGirl.build :event
      @event.location = nil
      @team = double("team")
      @team.stub(events: [@event])
      @team.stub(id: 1)
      @team.stub(name: "Tim")
      Team.stub(find_by_uuid: @team)
      get :index, uuid: "askjdfks", format: :ics
      response.status.should eq(200)
    end
  end

  describe "responding" do

      context 'responding yes via the email invite link' do      
        before :each do
          @user = FactoryGirl.create(:user, :with_team_events)
          @team = @user.teams_as_organiser.first
          @team_count = Team.count
          @event = @team.events.first

          @invited_user = FactoryGirl.create(:user, :as_invited, :invited_by_source => UserInvitationTypeEnum::EVENT)
          @teamsheet_entry = FactoryGirl.create(:teamsheet_entry, :event => @event, :user => @invited_user) 

          #Don't actually need to send the invite so just manually mark the invite as sent
          #@teamsheet_entry.send_invite()
          @teamsheet_entry.update_attributes(:invite_sent => true) 
          
          post :show, :token => @teamsheet_entry.token, :response => 'yes', :only_path => false, :format => 'html'

          @teamsheet_entry.reload
          @invited_user.reload
          @invite_response = InviteResponse.find_by_teamsheet_entry_id(@teamsheet_entry.id)
        end

        it 'marks that the invite has been sent out' do
          @teamsheet_entry.invite_sent.should be_true
        end

        it 'marks the user as available for the event' do
          @invite_response.response_status.should_not be_nil
          @invite_response.response_status.should == 1
        end

        it 'redirects to the event with correct availability' do
          should redirect_to(event_path(@event))
        end
      end

      context 'responding no via the email invite link' do      
        before :each do
          @user = FactoryGirl.create(:user, :with_team_events)
          @team = @user.teams_as_organiser.first
          @team_count = Team.count
          @event = @team.events.first

          @invited_user = FactoryGirl.create(:user, :as_invited, :invited_by_source => UserInvitationTypeEnum::EVENT)
          @teamsheet_entry = FactoryGirl.create(:teamsheet_entry, :event => @event, :user => @invited_user) 

          #Don't actually need to send the invite so just manually mark the invite as sent
          #@teamsheet_entry.send_invite()
          @teamsheet_entry.update_attributes(:invite_sent => true) 
          
          post :show, :token => @teamsheet_entry.token, :response => 'no', :only_path => false, :format => 'html'

          @teamsheet_entry.reload
          @invited_user.reload
          @invite_response = InviteResponse.find_by_teamsheet_entry_id(@teamsheet_entry.id)
        end

        it 'marks that the invite has been sent out' do
          @teamsheet_entry.invite_sent.should be_true
        end

        it 'marks the user as unavailable for the event' do
          @invite_response.response_status.should_not be_nil
          @invite_response.response_status.should == 0
        end

        it 'redirects to the event with correct availability' do
          should redirect_to(event_path(@event))
        end
      end
    end
end
