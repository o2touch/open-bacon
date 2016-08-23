require 'spec_helper'

describe EventMessageMailer do

  describe '#player_division_message_created' do
    before(:each) do
      @league = FactoryGirl.create(:league)
      @organiser = @league.organisers.first
      @division = FactoryGirl.create(:division_season, league: @league)
      @team = FactoryGirl.create(:team)
      TeamDSService.add_team(@division, @team)
      @event_message = FactoryGirl.create(:event_message, :user => @organiser, :messageable => @division)
      @user = FactoryGirl.create(:user, :name => "Bob Evans", :email => "bob@gmail.com")

      @data = {
        event_message_id: @event_message.id,
        actor_id: @event_message.user.id,
        team_id: @team.id,
        division_season_id: @division.id
      }

      @tenant_id = 1

      @mail = EventMessageMailer.player_division_message_created(@user.id, @tenant_id, @data)
    end

    it "should contain league name in body" do
      @mail.body.encoded.should match(@league.title)
    end

    it "should contain the message text" do
      @mail.body.encoded.should match(@event_message.text)
    end
  end

  describe '#parent_division_message_created' do
    before(:each) do
      @league = FactoryGirl.create(:league)
      @organiser = @league.organisers.first      
      @junior_user = FactoryGirl.create(:junior_user)
      @division = FactoryGirl.create(:division_season, league: @league)
      @team = FactoryGirl.create(:team)
      TeamDSService.add_team(@division, @team)
      @event_message = FactoryGirl.create(:event_message, :user => @organiser, :messageable => @division)
      @parent = @junior_user.parents.first

      @data = {
        event_message_id: @event_message.id,
        actor_id: @event_message.user.id,
        team_id: @team.id,
        division_season_id: @division.id
      }

      @tenant_id = 1

      @mail = EventMessageMailer.parent_division_message_created(@parent.id, @tenant_id, @data)
    end

    it "should contain league name in body" do
      @mail.body.encoded.should match(@league.title)
    end

    it "should contain the message text" do
      @mail.body.encoded.should match(@event_message.text)
    end
  end

  # TODO: #iwanttodie
  describe '#organiser_division_message_created'
  describe '#player_team_message_created'
  describe '#parent_team_message_created'
  describe '#organiser_division_message_created'
  describe '#player_event_message_created'
  describe '#parent_event_message_created'
  describe '#organiser_event_message_created'
end