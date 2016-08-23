require 'spec_helper'

describe DivisionSeasonMailer do

  describe '#organiser_division_launched' do
    before(:each) do

      @user = FactoryGirl.build(:user, :name => "Bob Evans", :email => "bob@gmail.com")
      @team = FactoryGirl.create(:team)
      @league = FactoryGirl.create(:league)
      @tenant = Tenant.first

      @team_invite = mock_model(TeamInvite)
      @team_invite.stub(:sent_to).and_return { @user }
      @team_invite.stub(:team).and_return { @team }
      @team_invite.stub(:token).and_return { "abcdef" }
      TeamInvite.stub(find: @team_invite)
      User.stub(find: @user)

      @data = {
        team_invite_id: 1,
        team_id: @team.id,
        league_id: @league.id
      }

      @mail = DivisionSeasonMailer.organiser_division_launched(@user.id, @tenant.id, @data)
    end

    it "should contain league name in body" do
      @mail.body.encoded.should match(@team.name)
      @mail.body.encoded.should match("Welcome")
      @mail.body.encoded.should match("captain")

      @mail.should deliver_to("Bob Evans <bob@gmail.com>")
      @mail.should deliver_from(@league.title + " via Mitoo <do_not_reply@mitoo.co>")
      @mail.should have_subject("Welcome to #{@league.title}, you are a captain of #{@team.name}")
    end
    
  end

  describe '#player_division_launched' do
    before(:each) do

      @user = FactoryGirl.build(:user, :name => "Bob Evans", :email => "bob@gmail.com")
      @team = FactoryGirl.create(:team)
      @league = FactoryGirl.create(:league)
      @tenant = Tenant.first

      @team_invite = mock_model(TeamInvite)
      @team_invite.stub(:sent_to).and_return { @user }
      @team_invite.stub(:team).and_return { @team }
      @team_invite.stub(:token).and_return { "abcdef" }

      TeamInvite.stub(find: @team_invite)
      User.stub(find: @user)

      @data = {
        team_invite_id: 1,
        team_id: @team.id,
        league_id: @league.id
      }

      League.stub!(:find).and_return(@league)
      TeamInvite.stub!(:find).and_return(@team_invite)

      @mail = DivisionSeasonMailer.player_division_launched(@user.id, @tenant.id, @data)
    end

    it "should contain league name in body" do
      @mail.body.encoded.should match("Welcome")
      @mail.body.encoded.should match(@league.title)
      @mail.body.encoded.should match("Bob")

      @mail.should deliver_from(@league.title + " via Mitoo <do_not_reply@mitoo.co>")
      @mail.should have_subject("Welcome to #{@league.title}")
      @mail.should deliver_to("Bob Evans <bob@gmail.com>")
    end
  end
end