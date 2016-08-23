# require 'AssetHostingWithMinimumSsl'
require 'ejs'
require 'metrics'

require 'event_invite_service'
require 'team_events_service'
require 'team_users_service'

# Set default root domain
# - used for base domain in session cookies
# - used for generating tenant-based subdomains (across environments)
$ROOT_DOMAIN = ENV['ROOT_DOMAIN'] if Rails.env.production?
$ROOT_DOMAIN = "stg1.mitoo.co" if Rails.env.staging?
$ROOT_DOMAIN = "demo.mitoo.co" if Rails.env.demo?
$ROOT_DOMAIN = "mitoo.local" if Rails.env.development?
$ROOT_DOMAIN = "127.0.0.1" if Rails.env.test?

# Dynamic Stylesheet Setup
TeamStylesheet.initial_setup

# don't do chunked transfer to s3 (because it fails)
Excon.defaults[:nonblock] = false