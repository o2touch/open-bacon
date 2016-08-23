class TeamSummaryMessageWorker
  include Sidekiq::Worker
  sidekiq_options queue:"aggregate-messages"

  def perform(messages)
    true
  end
end
