class DeadMessageWorker
  include Sidekiq::Worker
  sidekiq_options queue:"dead"

  def perform(message)
    true
  end
end
