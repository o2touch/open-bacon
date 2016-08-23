require 'development_mail_interceptor'
require 'staging_mail_interceptor'
require 'demo_mail_interceptor'

# ActionMailer::Base.register_interceptor(ProductionMailInterceptor) #All environments
ActionMailer::Base.register_interceptor(DevelopmentMailInterceptor) if Rails.env.development?
ActionMailer::Base.register_interceptor(StagingMailInterceptor) if Rails.env.staging?
ActionMailer::Base.register_interceptor(DemoMailInterceptor) if Rails.env.demo?

# the mailgun api key
MAILGUN_API_KEY = ENV['MAILGUN_API_KEY']

# some mail related constants
NOTIFICATIONS_FROM_ADDRESS="notifications@#{ENV['ROOT_DOMAIN']}"
DO_NOT_REPLY_FROM_ADDRESS="do_not_reply@#{ENV['ROOT_DOMAIN']}"
INCOMING_MAIL_DOMAIN="reply.#{ENV['ROOT_DOMAIN']}"