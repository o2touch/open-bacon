# Be sure to restart your server when you modify this file.

BluefieldsRails::Application.config.session_store :cookie_store, key: '_bluefields-rails_session'
# BluefieldsRails::Application.config.session_store :redis_store, servers: "#{ENV['REDIS_STORE_URL']}/1/sessions", expire_in: 259200, domain: ".#{$ROOT_DOMAIN}"