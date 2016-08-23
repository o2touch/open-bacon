require 'spec_helper'

describe ScheduledNotificationMailer do
  before :each do
    @tenant_id = 1
  end

  describe '#user_weekly_event_schedule' do

    let(:recipient) { FactoryGirl.create(:user) }

    before(:each) do
      @team = FactoryGirl.create(:team, :with_events)

      @data = {
        event_ids: @team.future_events.map { |e| e.id },
        time_until: Time.now + 9.days
      }
    end

    context "with events" do
      before :each do
        @mail = ScheduledNotificationMailer.user_weekly_event_schedule(recipient.id, @tenant_id, @data)
      end
      it "should contain event name in body" do
        @mail.body.encoded.should match(@team.future_events.first.title)
      end
    end

    context "unregistered with events" do
      before :each do
        recipient.stub(:is_registered?).and_return(false)

        User.stub(:find).and_return(recipient)
        User.should_receive(:find).with(recipient.id)

        @path = "#{user_path(recipient)}#user/#{recipient.id}/schedule"
        @power_token = PowerToken.create!(user: recipient, route: @path)
        PowerToken.stub(:generate_token).and_return(@power_token)

        @mail = ScheduledNotificationMailer.user_weekly_event_schedule(recipient.id, @tenant_id, @data)
      end
      it "should contain a link to log user in" do
        @mail.body.encoded.should match(power_token_url(:token => @power_token, :only_path => false ))
      end
    end

    context "with no events" do
      before :each do
        @data[:event_ids] = []
        @mail = ScheduledNotificationMailer.user_weekly_event_schedule(recipient.id, @tenant_id, @data)
      end
      it "returns NullMail" do
        @mail.should_be kind_of(ActionMailer::Base::NullMail)
      end
    end

  end

  describe '#parent_weekly_event_schedule' do

    let(:recipient) { FactoryGirl.create(:user) }
    let(:junior) { FactoryGirl.create(:user) }

    before(:each) do
      @team = FactoryGirl.create(:team, :with_events)

      recipient
      junior
      User.stub(:find) do |args|
        u = recipient if args==recipient.id
        u = junior if args==junior.id
        u
      end

      @data = {
        junior_id: junior.id,
        event_ids: @team.future_events.map { |e| e.id },
        time_until: Time.now + 9.days
      }
    end

    context "with events" do
      before :each do

        User.should_receive(:find).with(recipient.id)
        User.should_receive(:find).with(junior.id)

        @mail = ScheduledNotificationMailer.parent_weekly_event_schedule(recipient.id, @tenant_id, @data)
      end
      it "should contain recipient name in body" do
        @mail.body.encoded.should match(recipient.first_name)
      end
      it "should contain event name in body" do
        @mail.body.encoded.should match(@team.future_events.first.title)
      end
    end

    context "unregistered with events" do
      before :each do
        recipient.stub(:is_registered?).and_return(false)

        @path = "#{user_path(junior)}#user/#{junior.id}/schedule"
        @power_token = PowerToken.create!(user: recipient, route: @path)
        PowerToken.stub(:generate_token).and_return(@power_token)

        @mail = ScheduledNotificationMailer.parent_weekly_event_schedule(recipient.id, @tenant_id, @data)
      end
      it "should contain a link to log user in" do
        @mail.body.encoded.should match(power_token_url(:token => @power_token, :only_path => false ))
      end
    end

    context "with no events" do
      before :each do
        @data[:event_ids] = []
        @mail = ScheduledNotificationMailer.parent_weekly_event_schedule(recipient.id, @tenant_id, @data)
      end
      it "returns NullMail" do
        @mail.should_be kind_of(ActionMailer::Base::NullMail)
      end
    end

  end

end