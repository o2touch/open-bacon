module Metrics
  class EngagementAnalysis
    class << self

      # Get summary stats for period
      def summary(tenant_id=nil, unit=:month, start_date=nil)
        return {
          active_players: 1000,
          mobile_active: 1000
        }
      end

    end
  end
end