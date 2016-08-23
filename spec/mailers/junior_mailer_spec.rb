require 'spec_helper'
include EventUpdateHelper
include MailerHelper

describe JuniorMailer do

  def build_user(id)      
    user = FactoryGirl.build(:user, :id => id)
    User.should_receive(:find).once.with(id).and_return(user)
    user
  end
  
  def build_event(id)
    event = FactoryGirl.build(:event, :user => nil).tap do |event|
      event.id = id
    end
    event.user =  FactoryGirl.create(:user, :name => 'Cody Tandy', :email => 'founder@bluefields.com')
    event.team = FactoryGirl.create(:team)
    event.save
    Event.should_receive(:find).once.with(id).and_return(event)
    event
  end

  before :each do
    @tenant_id = 1
  end

  let(:parent) { build_user(1) }
  let(:junior) { build_user(2) }
  let(:organiser) { build_user(3) }

  describe "#event_updated email" do
    let(:event) { build_event(1) }

    context "event with multiple updates" do
      before(:each) do
        @updates = pretty_event_atributes({
          :title => [event.title, event.title.reverse],
          :location => [event.location.title, event.location.title.reverse],
          :time => [event.time, event.time + 1.day]
        })
        
        #@email = JuniorMailer.event_updated(parent.id, junior.id, event.id, @updates)
        @data = { junior_id: junior.id, event_id: event.id, updates: @updates }
        @email = EventMailer.parent_event_updated(parent.id, @tenant_id, @data)
      end

      it_behaves_like "an email received by a parent"

      describe "the email body" do
        it "should contain the event name" do
          @email.body.encoded.should match(event.title)
        end

        it "should contain the event updates" do
          @updates.each do |field, value|
            @email.body.encoded.should match(field)
            @email.body.encoded.should match(value)
          end
        end

        it "should contain the juniors name" do
          @email.body.encoded.should match(junior.first_name)
        end
      end
    end
  end

  describe "#event_activated email" do
    let(:event) { build_event(1) }

    before(:each) do
      #@email = JuniorMailer.event_activated(parent.id, junior.id, event.id)
      @data = { junior_id: junior.id, event_id: event.id }
      @email = EventMailer.parent_event_activated(parent.id, @tenant_id, @data)
    end

    it_behaves_like "an email received by a parent"

    describe "the email body" do
      it "should contain the event name" do
        @email.body.encoded.should match(event.title)
      end

      it "should contain the juniors name" do
        @email.body.encoded.should match(junior.first_name)
      end
    end
  end

  describe "#parent_invited_to_team" do
    let(:juniors) do
      [ 
        mock_model(User, :first_name => 'Aishwarya Rai'), 
        mock_model(User, :first_name => 'Priyanka Chopra'),
        mock_model(User, :first_name => 'Kareena Kapoor'),
      ].tap do |juniors|
        User.should_receive(:find).once.with(juniors.map(&:id)).and_return(juniors)
      end
    end

    before(:each) do
      # @juniors = [double('junior', :id => 1, :name => 'Aishwarya Rai')]
       junior_ids = juniors.map(&:id)
      # User.should_receive(:find).once.with(junior_ids).and_return(@juniors)

      @team = FactoryGirl.build(:team, :created_by => @organiser)
      @team.stub(:id).and_return(1)
      Team.should_receive(:find).once.with(@team.id).and_return(@team)

      @team_invite_token = 'token'

      @email = JuniorMailer.parent_invited_to_team(parent.id, @team.id, junior_ids, organiser.id, @team_invite_token)
    end

    it_behaves_like "an email received by a parent"

    describe "the email body" do
      it "should contain link" do
        link_url = team_invite_link_url(:token => @team_invite_token, :only_path => false)
        @email.body.encoded.should match(link_url)
      end

      it "should contain the team name" do
        @email.body.encoded.should match(%r{#{@team.name}}i)
      end

      it "should contain the juniors name" do
        juniors.each { |junior| @email.body.encoded.should match(junior.first_name) }
      end

      it "should contain the organiser name" do
        @email.body.encoded.should match(organiser.name)
      end
    end
  end

  describe "#event_cancelled" do
    context "sucessfull email" do
      before(:each) do
        @event = build_event(1)
        @parent = build_user(1)
        @junior = build_user(2)
        @organiser = build_user(3)

        #@mail = JuniorMailer.event_cancelled(@parent.id, @junior.id, @event.id, @organiser.id)
        @data = { junior_id: @junior.id, event_id: @event.id, actor_id: @organiser.id }
        @mail = EventMailer.parent_event_cancelled(@parent.id, @tenant_id, @data)
      end

      it "should contain the juniors name" do
         @mail.body.encoded.should match(@junior.first_name)
      end

      it "should contain the parent name" do
        @mail.body.encoded.should match(@parent.first_name)
      end

      it "should contain the organiser name" do
        # pending("Copy to be decided. Remove organiser from code if not required.") do
        #   @mail.body.encoded.should match(@organiser.first_name)
        # end
      end
    end
  end

  # MOVED TO TeamMailerSpec
  # These tests have been made to pass here and then moved into the TeamMailerSpec - PR
  # 
  # describe "#event_schedule_update" do
  #   context "sucessfull email" do
  #     before(:each) do

  #       @parent = FactoryGirl.build(:user)
  #       @junior = FactoryGirl.build(:user)
  #       @organiser = FactoryGirl.build(:user)

  #       @parent.stub(:id).and_return(1)
  #       @junior.stub(:id).and_return(2)
  #       @organiser.stub(:id).and_return(3)

  #       User.stub(:find) do |arg|
  #         u = @parent if arg == 1
  #         u = @junior if arg == 2
  #         u = [@junior] if arg == [2]
  #         u = @organiser if arg == 3
  #         u
  #       end

  #       event = FactoryGirl.build(:event, :user => @organiser)
  #       event.stub(:id).and_return(1)
  #       @events = [event]
  #       event_ids = @events.map(&:id)
  #       Event.should_receive(:find).once.with(event_ids, {:order=>"field(id, 1)"}).and_return(@events)

  #       @team = FactoryGirl.build(:team, :created_by => @organiser)
  #       @team.stub(:id).and_return(1)
  #       Team.should_receive(:find).once.with(@team.id).and_return(@team)

  #       #@mail = JuniorMailer.event_schedule_update(@parent.id, @junior.id, @organiser.id, @team.id, event_ids, 'token')
  #       TeamInvite.stub(find: double(token: 'token'))
  #       @data = { junior_id: @junior.id, actor_id: @organiser.id, team_id: @team.id, event_ids: event_ids, team_invite_id: 1}
  #       @mail = TeamMailer.parent_schedule_updated(@parent.id, @data)
  #     end

  #     it "should contain the team name" do
  #       @mail.body.encoded.should match(%r{#{@team.name}}i)
  #     end

  #     it "should contain the juniors name" do
  #       @mail.body.encoded.should match(@junior.first_name)
  #     end

  #     it "should contain the parent name" do
  #       @mail.body.encoded.should match(@parent.first_name)
  #     end

  #     it "should contain the organiser name" do
  #       # pending("Copy to be decided. Remove organiser from code if not required.") do
  #       #   @mail.body.encoded.should match(@organiser.name)
  #       # end
  #     end

  #     # it "should contain the updated events" do
  #     #   @events.each { |event| @mail.body.encoded.should match(event.title) }
  #     # end
  #   end
  # end

  describe "#event_schedule" do
    context "sucessfull email" do
      before(:each) do
        @parent = build_user(1)
        @organiser = build_user(2)

        @juniors = [double('junior', :id => 3, :first_name => 'Aishwarya Rai')]
        junior_ids = @juniors.map(&:id)
        User.should_receive(:find).once.with(junior_ids).and_return(@juniors)

        event = FactoryGirl.build(:event, :user => @organiser)
        event.stub(:id).and_return(1)
        @events = [event]
        event_ids = @events.map(&:id)
        Event.should_receive(:find).once.with(event_ids, {:order=>"field(id, 1)"}).and_return(@events)

        @team = FactoryGirl.build(:team, :created_by => @organiser)
        @team.stub(:id).and_return(1)
        Team.should_receive(:find).once.with(@team.id).and_return(@team)

        @mail = JuniorMailer.event_schedule(@parent.id, @team.id, junior_ids, @organiser.id, event_ids, 'token')
      end

      it "should contain the team name" do
        @mail.body.encoded.should match(%r{#{@team.name}}i)
      end

      it "should contain the juniors name" do
        @juniors.each { |junior| @mail.body.encoded.should match(junior.first_name) }
      end

      it "should contain the parent name" do
        @mail.body.encoded.should match(@parent.first_name)
      end

      it "should contain the organiser name" do
        # pending("Copy to be decided. Remove organiser from code if not required.") do
        #   @mail.body.encoded.should match(@organiser.name)
        # end
      end

      it "should contain the updated events" do
        @events.each { |event| @mail.body.encoded.should match(event.title) }
      end
    end
  end

  describe "#scheduled_event_reminder_multiple" do
    context "sucessfull email multiple day events" do
      before(:each) do
        @teamsheet_entries = FactoryGirl.build_list(:teamsheet_entry, 2)
        @teamsheet_entries.each_with_index do |tse, index| 
          tse.event.stub(:id).and_return(index+1)
          tse.stub(:response_status).and_return(InviteResponseEnum::AVAILABLE)
          tse.create_token
        end
        teamsheet_entry_ids = @teamsheet_entries.map(&:id)
        TeamsheetEntry.should_receive(:find).once.with(teamsheet_entry_ids).and_return(@teamsheet_entries)

        @parent = build_user(1)
        @junior = build_user(2)
        

        @mail = JuniorMailer.scheduled_event_reminder_multiple(@parent.id, @junior.id, teamsheet_entry_ids, false)
      end

      it "should contain the juniors name" do
        @mail.body.encoded.should match(@junior.first_name)
      end

      it "should contain the parent name" do
        @mail.body.encoded.should match(@parent.first_name)
      end

      it "should contain the upcoming events" do
        @teamsheet_entries.each { |tse| @mail.body.encoded.should match(tse.event.title) }
      end

      it "should contain available" do
        @mail.body.encoded.should match('available')
      end
    end
  end

  describe "#scheduled_event_reminder_single" do
    context "sucessfull email" do
      before(:each) do
        @teamsheet_entry = FactoryGirl.build(:teamsheet_entry)
        @teamsheet_entry.event.stub(:id).and_return(1)
        @teamsheet_entry.stub(:response_status).and_return(InviteResponseEnum::AVAILABLE)

        @teamsheet_entry.create_token
        TeamsheetEntry.should_receive(:find).once.with(@teamsheet_entry.id).and_return(@teamsheet_entry)

        @parent = build_user(1)
        @junior = build_user(2)

        @mail = JuniorMailer.scheduled_event_reminder_single(@parent.id, @junior.id, @teamsheet_entry.id)
      end

      it "should contain available" do
        @mail.body.encoded.should match('available')
      end

      it "should contain the juniors name" do
        @mail.body.encoded.should match(@junior.first_name)
      end

      it "should contain the parent name" do
        @mail.body.encoded.should match(@parent.first_name)
      end

      it "should contain the upcoming events" do
        @mail.body.encoded.should match(@teamsheet_entry.event.title)
      end
    end
  end

end

