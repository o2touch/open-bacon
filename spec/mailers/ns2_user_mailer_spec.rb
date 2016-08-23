require 'spec_helper'

describe Ns2UserMailer do
  before :each do
    @follower = FactoryGirl.create :user, country: "US"
    @follower_unregistered = FactoryGirl.create :user, country: "US"
    @follower_gb = FactoryGirl.create :user, country: "GB"
    @follower_no_locale = FactoryGirl.build :user, country: nil
    @inviter = FactoryGirl.create :user
    @tenant_id = 1

    @mock_team = FactoryGirl.create :team, :with_events, event_count: 1

    @data = {
      team_id: 1
    }

    @follower_unregistered.stub(:is_registered?).and_return(false)
    
    Team.stub(find: @mock_team)
    
    User.stub(:find) do |arg|
      u = @follower if arg == 1
      u = @follower_gb if arg == 2
      u = @follower_no_locale if arg == 3
      u = @inviter if arg == 4
      u = @follower_unregistered if arg == 5
      u
    end
  end

  describe '#process_schedule_data' do
    it 'should populate variables' do
      valid_data, recipient, team, league, events, team_invite_token = TeamMailer.process_schedule_data(1, @data)

      valid_data.should be_true
      # recipient.should == @user
    end
  end

  describe '#user_imported' do
    before :each do
      @team_invite = FactoryGirl.create :team_invite, sent_to: @follower_unregistered, sent_by: @inviter, team: @mock_team
      @data[:team_invite_id] = @team_invite.id
    end

    it 'should be a nice email' do
      mail = Ns2UserMailer.user_imported(5, @tenant_id, @data)
      mail.should_not be_a(ActionMailer::Base::NullMail)

      body = mail.body.encoded

      # body.should match(@mock_team.name.upcase)
      body.should match("#{team_invite_link_url(:token => @team_invite.token, :only_path => false )}")

      mail.should deliver_to("#{@follower_unregistered.name.titleize} <#{@follower_unregistered.email}>")
      mail.should deliver_from("Mitoo <#{NOTIFICATIONS_FROM_ADDRESS}>")

      mail.should have_subject("New mobile app for #{@mock_team.name} powered by Mitoo")
    end

  end

  describe '#user_imported_generic' do
    before :each do
      @data = {}
    end

    it 'should be a nice email' do
      mail = Ns2UserMailer.user_imported_generic(5, @tenant_id, @data)
      mail.should_not be_a(ActionMailer::Base::NullMail)

      body = mail.body.encoded

      # body.should match(@mock_team.name.upcase)

      mail.should deliver_to("#{@follower_unregistered.name.titleize} <#{@follower_unregistered.email}>")
      mail.should deliver_from("Mitoo <#{NOTIFICATIONS_FROM_ADDRESS}>")

      mail.should have_subject("#{@follower_unregistered.name.titleize}, a new mobile app for you powered by Mitoo")
    end

  end

  describe '#follower_registered' do
    it 'should be a nice email' do
      mail = Ns2UserMailer.follower_registered(1, @tenant_id, @data)
      mail.should_not be_a(ActionMailer::Base::NullMail)

      body = mail.body.encoded

      body.should match(@mock_team.name.upcase)
      # Download has been taken out
      # body.should match("http://127.0.0.1/download")
      body.should match("Know every game change as soon as it happens")

      mail.should deliver_to("#{@follower.name.titleize} <#{@follower.email}>")
      mail.should deliver_from("#{@mock_team.name} <#{NOTIFICATIONS_FROM_ADDRESS}>")

      #SR - comment about poor grammer made in mailer. 
      mail.should have_subject("#{@follower.first_name} You are now following #{@mock_team.name} on Mitoo")
    end

    context "locale is GB" do
      it 'should be a nice email' do
        mail = Ns2UserMailer.follower_registered(2, @tenant_id, @data)
        
        body = mail.body.encoded

        #body.should match("Upcoming game and ground information")
        #body.should_not match("Upcoming game and field information")
        #SR - We dont have specific copy for US and GB anymore.
      end
    end

    context "locale is not set" do
      it 'goes back to default locale' do
        mail = Ns2UserMailer.follower_registered(3, @tenant_id, @data)
        
        body = mail.body.encoded
        #SR - We dont have specific copy for US and GB anymore.
        # body.should match("Upcoming game and field information")
        # body.should_not match("Upcoming game and ground information")
      end
    end
  end

  describe '#follower_invited' do
    before :each do
      @team_invite = FactoryGirl.create :team_invite, sent_to: @follower_unregistered, sent_by: @inviter, team: @mock_team
      @data[:team_invite_id] = @team_invite.id
    end

    it 'should be a nice email' do
      mail = Ns2UserMailer.follower_invited(5, @tenant_id, @data)
      mail.should_not be_a(ActionMailer::Base::NullMail)

      body = mail.body.encoded

      body.should match(@mock_team.name.upcase)
      body.should match("#{team_invite_link_url(:token => @team_invite.token, :only_path => false )}")

      mail.should deliver_to("#{@follower_unregistered.name.titleize} <#{@follower_unregistered.email}>")
      mail.should deliver_from("#{@mock_team.name} <#{NOTIFICATIONS_FROM_ADDRESS}>")

      mail.should have_subject("#{@inviter.first_name.titleize} invited you to follow #{@mock_team.name} on Mitoo")
    end

  end

end