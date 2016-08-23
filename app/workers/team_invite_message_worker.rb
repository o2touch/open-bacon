class TeamInviteMessageWorker
  include Sidekiq::Worker
  sidekiq_options queue:"real-time-messages"

  def perform(message)
    notification_item = message['class'].constantize.find(message['id'])
    TeamInviteProcessor.new("").process(notification_item)
  end
end
