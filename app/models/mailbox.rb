class Mailbox
  attr_accessor :type
  attr_reader :messageable
  
  def initialize(messageable)
    @messageable = messageable
  end

  def notifications(options = {})
    notifs = NotificationReceipt.where(:recipient_id => @messageable.id)
  end
  
  def deliver_message(from, recipient, notification_item, mailer, email_type, delivered_at=Time.now)
    notification = EmailNotification.new
    notification.sender = from
    notification.delivered_at = delivered_at
    notification.mailer = mailer
    notification.email_type = email_type
    notification.notification_item = notification_item
    notification.save!

    reciept = NotificationReceipt.new
    reciept.recipient = recipient
    reciept.notification = notification
    reciept.save!

    notification.receipts << reciept

    notification
  end
end
