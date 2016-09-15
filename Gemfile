source 'http://rubygems.org'
ruby "1.9.3"

if RUBY_VERSION =~ /1.9/
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8
end

gem 'rails', '~> 3.2.14'
# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

# Rails
gem 'cache_digests' # Rails 4-like cache digests for view twmplates

gem 'puma'

# RABL
gem 'rabl', '~> 0.8.2'
gem 'json', '~> 1.7.6'
gem 'oj', '2.0.14'

gem 'httparty', '~> 0.10.0'
gem 'rest-client', '~> 1.6.7'

# gem 'sqlite3', '~> 1.3.7'
#gem 'activerecord-mysql2-adapter'
# gem 'less-rails', '~> 2.2.6'
gem 'draper', '~> 1.3'

# DEVISE
gem 'warden', '~> 1.2.1'
gem 'devise', '~> 2.2.1'
gem 'devise_invitable', '~> 1.0.0'
gem 'cancan', '~> 1.6.8'

gem 'geoip', '~> 1.2.1'
gem 'daemons', '~> 1.1.9'

# Administrative
gem "split", :require => 'split/dashboard'
gem "statsd-ruby"
gem "nunes"
gem "sidekiq-statsd"

# sidekiq and web interface dependencies
gem 'sinatra', :require => false
gem 'sidekiq', '~> 2.0' # 3.x doesn't support MRI 1.9
gem 'connection_pool'
gem 'celluloid'
gem 'slim', '>= 1.3.0'
gem 'devise-async'

# Cron replacement
gem 'clockwork'


gem 'gon', '~> 4.0.2'
# for JS templating
gem 'ejs'
gem 'rollout', '~> 2.0.0'
gem 'font-awesome-rails', '~> 3.0.1'
gem 'meta-tags', :require => 'meta_tags'

# Profile Pictures
# gem 'rack-cache', :require => 'rack/cache'

gem "paperclip", "~> 3.0"
gem "delayed_paperclip"
gem 'rmagick', '~> 2.13.1'

gem "fog", "~> 1.27"

# Third-party apis
## Communication services
gem 'twilio-ruby', '~> 3.11.1'
gem 'sendgrid', '~> 1.1.0'
gem 'pusher'
gem 'dirigible'
gem 'bitly'
## Search API
gem "algoliasearch-rails", :git => 'git://github.com/algolia/algoliasearch-rails.git'
## Metric tracking services
gem 'customerio'
gem 'intercom', '~> 1.0' # v2.x is breaking
#gem 'active_campaign'
gem 'google-analytics-rails'
gem 'newrelic_rpm', '~> 3.7'
gem 'mixpanel_client'
gem 'analytics-ruby', :git => 'git://github.com/segmentio/analytics-ruby.git', :tag => '0.5.4'# Segment.io
gem 'faraday', '~> 0.8.0'
gem 'keen'
## Geocoding
gem 'geocoder'
## General Admin
gem 'hipchat'

# Facebook Development
gem 'koala', '~> 1.6.0'
gem 'omniauth', '~> 1.0'
gem 'omniauth-facebook', '~> 1.4.1'

gem 'ri_cal'
gem "macaddr", "~> 1.6.5"
gem 'uuid'
gem 'redis'
gem 'tzinfo', '~> 0.3.33'
gem 'redis-rails'
gem 'redis-store'
gem 'bitset'

gem 'sass',   '~> 3.3'
gem 'sass-rails',   '~> 3.2.3'
gem 'bourbon'



gem 'colored', '~> 1.2'
gem 'color'

# elastic search
gem 'tire'

gem 'global_phone'
# for queueing, provided by iron.io
gem 'iron_mq'
gem 'ethon'#, '0.5.11' # next version causes exceptions


#gem 'mail'
#gem 'rollout-js'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platform => :ruby

  # gem 'compass-rails'

  gem 'uglifier', '2.1.1' #'>= 1.0.3'

  gem 'turbo-sprockets-rails3'
end


# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'

gem 'garb'

gem "nokogiri", '1.6.2'
gem "roadie", '2.3.4'

# gem 'libv8'

# Please do not comment. This gem is required for deploying! TS
gem 'therubyracer', '0.12.0', :platform => :ruby

gem "mail_view", "~> 1.0.3"

gem "useragent"

# Versioning gems
gem 'vestal_versions', :git => 'git://github.com/laserlemon/vestal_versions'

gem 'randexp'
gem 'systemu'

# Validation reporting
gem 'keen'

gem 'net-ssh', '~> 2.9.2'

group :production do
  gem 'newrelic-redis'
  # Use unicorn as the app server
  gem 'unicorn'
end

group :development do
  gem 'tlsmail'
  gem 'bullet'

  # Removed this because of incompatibility (To be fixed in 3.6.6)
  # gem 'newrelic_plugin'

  # Leo's CSS injection stuff
  # gem 'guard-livereload', :require _rb_intern2 false
  # gem 'rack-livereload'
  # gem 'rb-fsevent',       :require _rb_intern2 false

  # Deploy with Capistrano
  # *** If you upgrade this, we MUST change the sidekiq capistrano recipe. TS ***
  gem 'capistrano', '3.3.5', require: false
  gem 'capistrano-rails', '~> 1.1', require: false
  gem 'capistrano-bundler', '~> 1.1', require: false
  # gem 'capistrano-rvm', '~> 0.1', require: false
  gem 'capistrano-rbenv'

  if RUBY_PLATFORM.downcase.include?("darwin")
    gem 'rb-fsevent'
    gem 'growl'
  end

  gem 'rails_12factor' # for heroku

  gem 'require_reloader'

  gem 'awesome_print'

  # setup local environment
  gem 'dotenv-rails', :require => 'dotenv/rails-now'
end

group :staging do
  gem 'rb-fsevent'
  gem 'growl'
end

gem 'factory_girl', '4.4' #For use in mailer previews only

group :test do
  # gem 'awesome_print'
  # gem "poltergeist"
  # gem "factory_girl_rails", '4.4'
  # gem "capybara"
  # gem "chromedriver-helper" # required to use chrome with selenium
  # gem "guard-rspec", '3.0.1'
  # gem 'database_cleaner'
  # gem 'rspec-redis_helper', '0.1.2'
  # gem 'fakeredis', :git => 'git@github.com:prollinson/fakeredis.git', :require => "fakeredis/rspec"
  # gem 'pusher-fake', '0.14.0'
#   gem 'sms-spec'
#   gem 'email_spec'
#   #gem 'spork', '~> 1.0rc'
#   gem 'spork-rails'
#   gem 'simplecov'
#   gem 'timecop', "~> 0.6.2"
#   gem 'selenium-webdriver'
#   gem "codeclimate-test-reporter", group: :test, require: nil
end

group :development, :production do
  gem 'mysql2', "~> 0.3.10"
end

group :development, :test do
  gem "jasmine", '1.3.2' # jasmine needs to be in dev as well
  gem 'ruby-prof'
  gem "rspec-rails", '2.13.2'
  #gem 'jasmine-headless-webkit'
  #gem 'jasmine-rails'
end
