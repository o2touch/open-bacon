#require "codeclimate-test-reporter"
#CodeClimate::TestReporter.start

require 'rubygems'
require 'spork'

#uncomment the following line to use spork with the debugger
#require 'spork/ext/ruby-debug'

Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However,
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.

  # trap some calls, so spork notices changes to routes and models etc.
  # https://github.com/sporkrb/spork/wiki/Spork.trap_method-Jujitsu
  require "rails/application"
  Spork.trap_method(Rails::Application, :reload_routes!)
  Spork.trap_method(Rails::Application::RoutesReloader, :reload!) 
  Spork.trap_method(Rails::Application, :eager_load!)

  # This file is copied to spec/ when you run 'rails generate rspec:install'
  ENV["RAILS_ENV"] ||= 'test'
  require 'rspec/core'
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'
  require 'rspec/autorun'
  require 'capybara/poltergeist'
  require 'factory_girl_rails'
  require 'sms_spec'
  require 'email-spec'
  require 'simplecov'
  
  require 'sidekiq/testing'
  require 'celluloid/autostart'
  
  # Code Coverage Tool
  SimpleCov.start do
    add_filter '/spec/'
    add_filter '/config/'
    add_filter '/lib/'
    add_filter '/vendor/'

    add_group 'Controllers', 'app/controllers'
    add_group 'Models', 'app/models'
    add_group 'Helpers', 'app/helpers'
    add_group 'Mailers', 'app/mailers'
    add_group 'Views', 'app/views'
  end if ENV["COVERAGE"]

  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

  # Mock OmniAuth 
  OmniAuth.config.test_mode = true
  omniauth_hash = {
    :provider => "facebook",
    :uid      => "1234567",
    :info   => {
      :name       => "John Doe",
      :email      => "johndoe@email.com"
    },
    :credentials => {
       :token => "testtoken234tsdf"
     },
    :extra  => {
      :raw_info => {
        :email => "johndoe@email.com",
        :first_name => "John",
        :last_name  => "Doe"
      }
    }
  }
  OmniAuth.config.add_mock(:facebook, omniauth_hash)

  # FakePusher
  PusherFake.configure do |configuration|
    configuration.app_id = Pusher.app_id
    configuration.key    = Pusher.key
    configuration.secret = Pusher.secret
  end

  # Geocoder setup for testing
  Geocoder.configure(:lookup => :test)
  Geocoder::Lookup::Test.set_default_stub(
    [
      {
        'latitude'     => 40.7143528,
        'longitude'    => -74.0059731,
        'address'      => 'New York, NY, USA',
        'city'        => 'New York City',
        'state'        => 'New York',
        'state_code'   => 'NY',
        'country'      => 'United States',
        'country_code' => 'US',
        'postal_code' => 10007
      }
    ]
  )

  RSpec.configure do |config|
    # ## Mock Framework
    #
    # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
    #
    # config.mock_with :mocha
    # config.mock_with :flexmock
    # config.mock_with :rr

    # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
    #config.fixture_path = "#{::Rails.root}/spec/fixtures"

    # If you're not using ActiveRecord, or you'd prefer not to run each of your
    # examples within a transaction, remove the following line or assign false
    # instead of true.
    config.use_transactional_fixtures = true

    # If true, the base class of anonymous controllers will be inferred
    # automatically. This will be the default behavior in future versions of
    # rspec-rails.
    config.infer_base_class_for_anonymous_controllers = false

    config.treat_symbols_as_metadata_keys_with_true_values = true

    config.include Capybara::DSL # Fix problem with visit method

    # Devise Helpers
    config.include Devise::TestHelpers, :type => :controller
    config.include ControllerMockMacros, :type => :controller
    config.extend ControllerMacros, :type => :controller
    config.include RequestHelpers
    config.include MailerMacros

    config.include TeamUrlHelper

    # Database Cleaner
    config.before(:suite) do
      DatabaseCleaner.strategy = :truncation
    end

    config.after(:suite) do
      # Clear Dynamic stylesheets
      TeamStylesheet.clear_all
    end

    config.before(:each) do |example_method|
      Rails.cache.clear
      DatabaseCleaner.start
      load "#{Rails.root}/db/seeds.rb" #Load static data into the test DB
      
      #Reset mail deliveries
      reset_emails

      #Reset delayed job
      Sidekiq::Worker.clear_all

      example = example_method.example
      if example.metadata[:sidekiq] == :fake
        Sidekiq::Testing.fake!
      elsif example.metadata[:sidekiq] == :inline
        Sidekiq::Testing.inline!
      elsif example.metadata[:type] == :acceptance
        Sidekiq::Testing.inline!
      else
        Sidekiq::Testing.fake!
      end
      
      # Handle observers
      # disable all the observers
      ActiveRecord::Base.observers.disable :all
      # find out which observers this spec needs
      observers = example.metadata[:observer] || example.metadata[:observers]
      # turn on observers as needed
      if observers
        ActiveRecord::Base.observers.enable *observers
      end
    end

    config.after(:each) do
      # Warden.test_reset!
      Rails.cache.clear
      DatabaseCleaner.clean
      PusherFake::Channel.reset
    end

    # Redis
    config.include RSpec::RedisHelper, redis: true

    # clean the Redis database around each run
    # @see https://www.relishapp.com/rspec/rspec-core/docs/hooks/around-hooks
    config.around( :each, redis: true ) do |example|
      with_clean_redis do
        example.run
      end
    end

    config.around(:each, :caching) do |example|
      caching = ActionController::Base.perform_caching
      ActionController::Base.perform_caching = true
      example.run
      Rails.cache.clear
      ActionController::Base.perform_caching = false
    end

    # Email 
    config.include(EmailSpec::Helpers)
    config.include(EmailSpec::Matchers)
  end

RSpec.configure do |config|
  config.before do
    # disable all the observers
    ActiveRecord::Base.observers.disable :all

    # find out which observers this spec needs
    observers = example.metadata[:observer] || example.metadata[:observers]

    # turn on observers as needed
    if observers
      ActiveRecord::Base.observers.enable *observers
    end
  end
end

Capybara.default_wait_time = 15

  # Capybara.register_driver :poltergeist do |app|
  #   options = { :js_errors => false, :browser => :chrome }
  #   Capybara::Poltergeist::Driver.new(app, options)
  # end
  # Capybara.javascript_driver = :poltergeist

  # Capybara.register_driver :selenium do |app|
  #   Capybara::Selenium::Driver.new(app, :browser => :chrome)
  # end
  # Capybara.javascript_driver = :chrome

  # Common Variables
  @homepageTitle = "Organize your sports team without the hassle"

  # Optional custom spec helper e.g. use Chrome for capybara tests (see commented code above)
  require 'custom_spec_helper' if File.exists?(Rails.root+"spec/custom_spec_helper.rb")

  def time
    start = Time.now
    yield
    Time.now - start
  end
end

Spork.each_run do
  # This code will be run each time you run your specs.
  
  # Start the fake web server.
  fork { PusherFake::Server.start }.tap do |id|
    at_exit { Process.kill("KILL", id) }
  end
  FactoryGirl.reload # uncomment to get spork to notice edits to factories
end

RSpec.configure do |config|
  config.before(:each, sidekiq: false) do
      # Disable/enable hooks by uncommenting/commenting below code blocks
      module Sidekiq::Extensions::Klass
        alias_method :delay_old, :delay
        remove_method :delay

        def delay(options={})
          self
        end
      end
     

      module Sidekiq::Extensions::ActionMailer
        alias_method :delay_old, :delay
        remove_method :delay

        def delay(options={})
          self
        end
      end
  end

  config.after(:each, sidekiq: false) do
     module Sidekiq::Extensions::Klass
        remove_method :delay
        alias_method :delay, :delay_old
      end
     

      module Sidekiq::Extensions::ActionMailer
        remove_method :delay
        alias_method :delay, :delay_old
      end

    
  end
end

def stop_sidekiq
    Sidekiq::Extensions::Klass.class_eval do
      alias_method :delay_old, :delay
      remove_method :delay

      def delay(options={})
        self
      end

    end

    Sidekiq::Worker::ClassMethods.class_eval do
      alias_method :perform_async_old, :perform_async
      remove_method :perform_async

      def perform_async(*args)
        self.new.perform(*args)
      end
    end
  
    Sidekiq::Extensions::ActionMailer.class_eval do
      alias_method :delay_old, :delay
      remove_method :delay

      def delay(options={})
        self
      end
    end
  end

  def start_sidekiq
    Sidekiq::Extensions::Klass.class_eval do
      remove_method :delay
      alias_method :delay, :delay_old
    end
    
    Sidekiq::Worker::ClassMethods.class_eval do
      remove_method :perform_async
      alias_method  :perform_async, :perform_async_old
    end

    Sidekiq::Extensions::ActionMailer.class_eval do
      remove_method :delay
      alias_method :delay, :delay_old
    end
  end
