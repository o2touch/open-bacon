class MessageRouterWorker
  include Sidekiq::Worker
  sidekiq_options queue:"messages"

  def perform(message)
    Onyx::MessageRouter.new.route(message)
  end
end
