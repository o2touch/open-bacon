# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
BluefieldsRails::Application.initialize!

# To prevent cache failing if model classes are not loaded in memory
if ENV['RAILS_ENV'] != 'test'
	Rails.application.eager_load!
end

# hide
Tilt::CoffeeScriptTemplate.default_bare = true

# Analytics Gem configuration with Passenger
if defined?(PhusionPassenger)
  PhusionPassenger.on_event(:starting_worker_process) do |forked|
    if forked # We're in smart spawning mode.
      Analytics = AnalyticsRuby     # Alias for convenience
      Analytics.init({
        secret: 'a99rbnlfwg464l0chaw1',
        on_error: Proc.new { |status, msg| print msg }
      })
    else
      # We're in direct spawning mode. We don't need to do anything.
    end
  end
end

# GC Performance
GC.enable_stats if defined?(GC) && GC.respond_to?(:enable_stats)