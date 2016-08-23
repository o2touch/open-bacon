require 'spec_helper'

describe UserMailer do

  describe '#scheduled_event_reminder_single' do

    before(:each) do

      @user = FactoryGirl.build(:user)
      @event = FactoryGirl.create(:event)

      tse = mock_model(TeamsheetEntry)
      tse.stub(:id).and_return(1)
      tse.stub(:user).and_return(@user)
      tse.stub(:event).and_return(@event)
      tse.stub(:response_status).and_return(InviteResponseEnum::AVAILABLE)
      tse.stub(:token).and_return("abcdef")

      @mail = UserMailer.scheduled_event_reminder_single(tse)
    end

    it "should contain event name in body" do
      @mail.body.encoded.should match(@event.title)
    end

    it "should contain available" do
      @mail.body.encoded.should match("available")
    end
  end

  describe '#scheduled_event_reminder_multiple' do

    before(:each) do
      @user = FactoryGirl.create(:user)
      @team = FactoryGirl.create(:team)
      @tses = FactoryGirl.create_list(:teamsheet_entry, 2, :user => @user)

      #TODO SR - MAKE FACTORY SMARTER/NEATER
      @event1 = @tses[0].event
      @event1.team = @team
      
      @event2 = @tses[1].event
      @event2.team = @team
      
      @mail = UserMailer.scheduled_event_reminder_multiple(@user, @tses)
    end

    it "should contain both event titles" do
      @mail.body.encoded.should match(@event1.title)
      @mail.body.encoded.should match(@event2.title)
    end

    it "should contain available" do
      @mail.body.encoded.should match("available")
    end
  end

  describe "#new_user_invited_to_team" do

    before(:each) do
      team = FactoryGirl.create(:team)
      organiser = team.founder
      user = FactoryGirl.create(:user)
      @team_invite_token = 'token'
      
      @mail = UserMailer.new_user_invited_to_team(user.id, team.id, organiser.id, @team_invite_token)
    end

    it "should contain 'Join the team'" do
      @mail.body.encoded.should match("Join the team")
    end

    it "should contain link" do
      link_url = team_invite_link_url(:token => @team_invite_token, :only_path => false )
      @mail.body.encoded.should match(link_url)
    end

  end

  describe '#comment_from_email_failure' do
    before :each do
      @address = "tim@bluefields.net.uk"
      @in_reply_to = "sskdjahf.39416294723.kasdfh@bluefields.net.uk"
      @mail = UserMailer.comment_from_email_failure(@address, @in_reply_to)
    end

    it 'should have a reply-to header' do
      @mail.should have_header('In-Reply-To', @in_reply_to)
    end
    it 'should have correct to address' do
      @mail.should deliver_to(@address)
    end
    it 'should have good copy' do
      @mail.body.encoded.should_not match("CUNT")
    end
    it 'should call correct from helper' do
      UserMailer.any_instance.should_receive(:determine_mail_from_for_automated_email).with(kind_of(Tenant))
      UserMailer.comment_from_email_failure(@address, @in_reply_to)
    end
  end
end