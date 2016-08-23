#Not to be confused with template helpers
#All time related functions should be in this module
class TimeHelpers
  class << self
    def compare_string_vs_object(time_string, time)
      Time.parse(time_string).utc == time.utc
    end
  end
end