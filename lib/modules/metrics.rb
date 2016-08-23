require 'bitset'

require 'metrics/query'
require 'metrics/tools'
require 'metrics/team_analysis'
require 'metrics/user_analysis'

module Metrics

  CACHE_KEY = "metrics_analysis_service:v1"

  class << self

    def feature_usage
      features = []
      
      # Reply by Email
      hash = {
        name: "Reply by Email",
        desc:"Allow people to comment by replying to an email",
        date: Date.parse("24/6/2013"),
        event_name: 'Posted Comment'
      }
      weeks_since = ((Date.today - hash[:date]).to_i / 7.0).ceil
      hash[:data] = $mixpanel_client.request('events', {
        event: ['Posted Comment'],
        type: 'unique',
        unit: 'week',
        interval: weeks_since
      })
      features << hash

      # Starred Messages
      # hash = {
      #   name: "Starred Messages",
      #   desc:"Allow organisers to highlight messages",
      #   date: Date.parse("24/6/2013"),
      #   event_name: 'Posted Comment'
      # }

      # Another feature here..

      features
    end
  end

end