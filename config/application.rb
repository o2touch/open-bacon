require File.expand_path('../boot', __FILE__)

require 'rails/all'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development staging test demo)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module BluefieldsRails
  class Application < Rails::Application
    # Require system constants prior to /lib and /model
    require "#{config.root}/lib/bf_system_constants"
    require "#{config.root}/lib/custom_errors"
    
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)
    config.autoload_paths += %W(#{config.root}/lib)
    config.autoload_paths += Dir["#{config.root}/lib/**/"]  # include all subdirectories
    config.autoload_paths += %W(#{config.root}/app/models/alien_processor)
    config.autoload_paths += Dir[Rails.root.join('app', 'models', '{**}')]
    config.autoload_paths += %W(#{config.root}/services)
    config.autoload_paths += %W(#{config.root}/pushers)
    config.autoload_paths += %W(#{config.root}/presenters)
    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]http://news.ycombinator.com/

    # Activate observers that should always be running.
    #config.active_record.observers = #:team_invite_observer#, :event_message_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.enforce_available_locales = false # This should be set to true as default
    config.i18n.default_locale = 'en-US'

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    # config.active_record.schema_format = :sql

    # Enforce whitelist mode for mass assignment.
    # This will create an empty whitelist of attributes available for mass-assignment for all models
    # in your app. As such, your models will need to explicitly whitelist or blacklist accessible
    # parameters by using an attr_accessible or attr_protected declaration.
    config.active_record.whitelist_attributes = true

    # Enable the asset pipeline
    config.assets.enabled = true
    config.assets.digest = true
    config.assets.precompile += ['default.js', 'app-public.js', 'analytics/init.js', 'fix/ie8.js', 'app-public.css','default.css', 'app-admin.css', 'app-admin.js', 'app-event-search.css', 'app-event-search.js']
    
    config.assets.paths << "#{Rails.root}/vendor/assets/templates"
    
    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'
        
    # Roadie
    config.roadie.enabled = true

    config.generators do |g|
      g.test_framework :rspec,
        :fixtures => true,
        :view_specs => false,
        :helper_specs => false,
        :routing_specs => false,
        :controller_specs => true,
        :request_specs => true
      g.fixture_replacement :factory_girl, :dir => "spec/factories"
    end

    config.to_prepare do
        # Override Devise Layouts
        Devise::PasswordsController.layout "basic"
    end

    #config.compass.sass_dir = "app/stylesheets"
    
    ## KEEP THIS - MU-AN 11 MAY 2012 - it's to do with form errors - class: field_with_errors
    # config.action_view.field_error_proc = Proc.new { |html_tag, instance| 
      # # looking for if there's class attr in input
      # class_attr_index = html_tag.index 'class="'
      # if class_attr_index
        # # insert 'error ' right after //class="// which is from [7]
        # html_tag.insert class_attr_index+7, 'error '
      # else
        # # if there's to attr called class, just add it in
        # html_tag.insert html_tag.index('>'), ' class="error"'
      # end
    # }
  end
end
