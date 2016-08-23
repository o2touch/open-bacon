module Metrics
  class NotificationAnalysis
    class << self

def last_30_day(medium, day)

  start_date = day - 30.days
  end_date = day

  series = []
  results = []

  (start_date..end_date).each do |date|
    result = {}
    result[:day] = date.strftime("%Y-%m-%d")

    notifications = self.by_medium_in_day(medium, date)

    notifications.each do |k, item|
      result[k] = item
      series << k unless series.include? k
    end

    results << result
  end

  return {
    data: results,
    series: series
  }
end

###
# BY MEDIUM
###
def by_medium_in_day(medium, day, user_ids=nil, clear_cache=false)
  return self.by_medium_in_period(medium, day, day, user_ids, clear_cache)
end

def by_medium_in_week(medium, week, year=2013, user_ids=nil, clear_cache=false)
  wk_begin, wk_end = self.get_week_begin_and_end(week, year)
  return self.by_medium_in_period(medium, wk_begin, wk_end, user_ids, clear_cache)
end

def by_medium_in_month(medium, month, user_ids=nil, clear_cache=false)
  m_begin, m_end = self.get_month_begin_and_end(month)
  return self.by_medium_in_period(medium, m_begin, m_end, user_ids, clear_cache)
end

def by_medium_in_last_30_days(day, user_ids=nil, clear_cache=false)
  date_begin = day - 30.days
  date_end = day
  return self.by_medium_in_period(medium, date_begin, date_end, user_ids, clear_cache)
end

def by_medium_in_period(medium, start_date, end_date, user_ids=nil, clear_cache=false)

  nis = {}

  start_date_str = start_date.strftime("%Y-%m-%d")
  end_date_str = end_date.strftime("%Y-%m-%d")
  clear_cache = true if end_date >= Date.today

  results = Metrics::Tools.execute_cached_query(Metrics::Query.notification_by_medium_query(medium, start_date_str, end_date_str, user_ids), clear_cache)
  results.each do |row|

    key = row[1]
    nis[key] = 0 unless nis.has_key? key

    nis[key] += 1
  end

  return nis
end


  def get_month_begin_and_end(month)
    m_begin = month.at_beginning_of_month
    m_end = month.at_end_of_month

    return m_begin, m_end
  end

end
end
end