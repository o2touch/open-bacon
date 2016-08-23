# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)
run BluefieldsRails::Application

# New relic Developer mode
# require 'newrelic_rpm'
# require 'new_relic/rack/developer_mode'
# use NewRelic::Rack::DeveloperMode