require 'spec_helper'

describe EventRescheduledProcessor do
  def build_mock_notification_item
    mock_recipient = mock_model(User)
    mock_recipient.stub(:mailbox).and_return(Mailbox.new(nil))

    mock_event = mock_model(Event)
    mock_event.stub(:invitees).and_return([mock_recipient])

    mock_user = mock_model(User)

    mock_notification_item = mock_model(NotificationItem)
    mock_notification_item.stub(:obj_type).and_return(Event.name)
    mock_notification_item.stub(:obj).and_return(mock_event)
    mock_notification_item.stub(:subj).and_return(mock_user)
    mock_notification_item.stub(:subj_type).and_return(User.name)
    mock_notification_item.stub(:verb).and_return(VerbEnum::RESCHEDULED)

    mock_notification_item
  end

  describe 'process' do
    it 'rejects message if the obj_type is not recognised' do
      mock_notification_item = double('notification_item')
      mock_notification_item.stub(:verb).and_return(VerbEnum::POSTPONED)
      mock_notification_item.stub(:obj_type).and_return("Object")

      EventRescheduledProcessor.new('processor').process(mock_notification_item).should be_false
    end

    it 'rejects message if the verb is not recognised' do
      mock_notification_item = double('notification_item')
      mock_notification_item.stub(:verb).and_return('destroyed')
      mock_notification_item.stub(:obj_type).and_return(Event.name)

      EventRescheduledProcessor.new('processor').process(mock_notification_item).should be_false
    end

    it 'sends a delayed event rescheduled email to the user', :sidekiq => false do
      mock_notification_item = build_mock_notification_item

      user = mock_notification_item.subj
      event = mock_notification_item.obj

      event.invitees.each do |u|
        u.mailbox.should_receive(:deliver_message).once
        UserMailer.should_receive(:event_rescheduled).once.with(event.id, u.id, user.id)
      end

      EventRescheduledProcessor.new('processor').process(mock_notification_item).should be_true
    end
  end
end
