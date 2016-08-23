class LeagueTeamInviteMessageWorker
  include Sidekiq::Worker
  sidekiq_options queue:"real-time-messages"

  def perform(message)
    notification_item = message['class'].constantize.find(message['id'])
    LeagueTeamInviteProcessor.new("").process(notification_item)
  end
end
