# Disable/enable hooks by uncommenting/commenting below code blocks
# module Sidekiq::Extensions::Klass
#   alias :sidekiq_delay :delay
#   remove_method :delay
#   alias :sidekiq_delay_for :delay_for
#   remove_method :delay_for
#   alias :sidekiq_delay_until :delay_until
#   remove_method :delay_until
# end
# module Sidekiq::Extensions::ActiveRecord
#   alias :sidekiq_delay :delay
#   remove_method :delay
#   alias :sidekiq_delay_for :delay_for
#   remove_method :delay_for
#   alias :sidekiq_delay_until :delay_until
#   remove_method :delay_until
# end
# module Sidekiq::Extensions::ActionMailer
#   alias :sidekiq_delay :delay
#   remove_method :delay
#   alias :sidekiq_delay_for :delay_for
#   remove_method :delay_for
#   alias :sidekiq_delay_until :delay_until
#   remove_method :delay_until
# end

url = ENV['REDIS_STORE_URL'] + '/2'

SIDEKIQ_NAMESPACE = 'mt-sidekiq'

Sidekiq.configure_server do |config|  
  config.redis = { :url => url, :namespace => SIDEKIQ_NAMESPACE }
  config.poll_interval = 1
  config.server_middleware do |chain|
    chain.add Sidekiq::Statsd::ServerMiddleware, env: Rails.env, prefix: "worker", statsd: $statsd
  end
end

Sidekiq.configure_client do |config|
  config.redis = { :url => url, :namespace => SIDEKIQ_NAMESPACE }
end
