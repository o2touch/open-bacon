web: bundle exec puma -C config/puma.rb
worker: bundle exec sidekiq -q default,4 -q pusher,4 -q messages,4 -q real-time-messages,2 -q aggregate-messages,2 -q ns2-delivery-queue,4 -q ns2-sms-delivery-queue,1 -q ns2-app-events,2 -q paperclip,1
