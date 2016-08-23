ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'factory_girl_rails'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  #fixtures :all

  # Add more helper methods to be used by all tests here...
  def seed_data
    Role.delete_all
    RoleEnum.values.each { |role| Role.create(name:role) }
  end

  def caching(&block)
  	caching = ActionController::Base.perform_caching
    ActionController::Base.perform_caching = true
    block.call
    Rails.cache.clear
    ActionController::Base.perform_caching = caching
  end
end
