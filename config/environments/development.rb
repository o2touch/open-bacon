BluefieldsRails::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # CACHING (Should be false in development, except when testing performance)
  if ENV['BLUEFIELDS_CACHE'] == '1'
  config.cache_store = :redis_store, ENV['REDIS_STORE_URL'] + '/3/cache'
    config.action_controller.perform_caching = true
  else
    config.cache_store = :null_store
    config.action_controller.perform_caching = false
  end

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
          
  # ActionMailer Config
  require 'tlsmail'
  Net::SMTP.enable_tls(OpenSSL::SSL::VERIFY_NONE)
  config.action_mailer.default_url_options = { :host => 'localhost', :port => 3000 }
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    :address              => "set me",
    :port                 => 587,
    :domain               => "set me",
    :user_name            => "set me",
    :password             => "set me",
    :authentication       => 'plain',
    :enable_starttls_auto => true
  }

  # change to false to prevent email from being sent during development
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.default :charset => "utf-8"

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Raise exception on mass assignment protection for Active Record models
  config.active_record.mass_assignment_sanitizer = :strict

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  config.active_record.auto_explain_threshold_in_seconds = 0.5

  # Assets: cache busting
  config.assets.digest = false
  # Assets: compression
  config.assets.compress = false
  # Assets: debug mode (if true disables concatenation)
  config.assets.debug = true


  config.domain = 'mitoo.local:3000'
  
  config.asset_host = 'mitoo.local:3000'


end

# Vanity Settings
# Vanity.playground.collecting = true