require 'spec_helper'

describe Mailbox do
  it 'stores the message' do
    mailbox = Mailbox.new(nil)
    from = FactoryGirl.create(:user)
    recipient = FactoryGirl.create(:user)
    team = FactoryGirl.create(:team)
    notification_item = FactoryGirl.create(:notification_item, :subj => from, :obj => team)
    mailer = UserMailer.name
    email_type = 'email_method'
    delivered_at = Time.now
    notification = mailbox.deliver_message(from, recipient, notification_item, mailer, email_type, delivered_at)

    notification.sender.should == from
    notification.delivered_at.should == delivered_at
    notification.mailer.should == mailer
    notification.email_type.should == email_type
    notification.notification_item.should == notification_item
    notification.receipts.count.should == 1
    receipt = notification.receipts.first
    receipt.recipient.should == recipient
    receipt.notification.should == notification
    notification.recipients.should == [recipient]
  end

  it 'returns notifications for the messagable' do
    from = FactoryGirl.create(:user)
    recipient = FactoryGirl.create(:user)
    mailbox = Mailbox.new(recipient)
    team = FactoryGirl.create(:team)
    notification_item = FactoryGirl.create(:notification_item, :subj => from, :obj => team)
    mailer = UserMailer.name
    email_type = 'email_method'
    delivered_at = Time.now
    notification = mailbox.deliver_message(from, recipient, notification_item, mailer, email_type, delivered_at)

    mailbox.notifications.count.should == 1
    mailbox.notifications[0].should == notification.receipts[0]
  end
end
