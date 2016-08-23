class BFTime

  attr_reader :utc_time, :time, :time_zone_str, :time_tbc

  TOMMOROW = 'Tommorow'
  SINGLE_SPACE = ' '
  DOUBLE_SPACE = SINGLE_SPACE*2
  
  def initialize(utc_time, time_zone_str, time_tbc=false)
    @utc_time = utc_time
    @time_zone_str = time_zone_str
    @time_tbc = time_tbc
    @time_zone = BFTimeLib.time_zone_info(time_zone_str)
    @pretty_time_zone_str = @time_zone.friendly_identifier(true)
    @time = BFTimeLib.utc_to_local(utc_time, time_zone_str)
  end
  
  def tbd?
    return @time.nil?
  end

  def time_tbd?
    return @time_tbc
  end

  def pp_time_zone
    "#{@pretty_time_zone_str} Time"
  end

  def day
    local_format(:day)
  end

  def weekday
    local_format(:weekday)
  end

  def weekday_or_tommorow(now=Time.now)
    tommorow?(now) ? TOMMOROW : self.weekday
  end

  def month
    local_format(:month)
  end

  def twelve_hour_time #Need better naming
    format = @time_tbc ? :tbc : :twelve_hour_time
    local_format(format)
  end

  def pp_sms_time
    time = local_format(:sms)
    time.sub(/[0-9]*<o>/, "#{self.day.to_i.ordinalize.to_s}").sub('AM', 'am').sub('PM', 'pm')
  end

  def pp_time
    #SR - Can't find out how to format dates with ordinal numbers within the locale files
    #SR - Can't override uppercase meridian indicators. See test example at:
    #https://github.com/alakra/i18n/blob/bf144bfd58f000d4e7fc7df066dcb04c6820bb79/lib/i18n/tests/localization/time.rb
    time = local_format(:casual)
    /,\s(.+)o/.match(time)
    time.sub(/,\s(.+)o/, ",\s#{$1.to_i.ordinalize.to_s}").sub('AM', 'am').sub('PM', 'pm')
  end

  private
  def tommorow?(now)
    (@utc_time - now.utc) < 1.day.to_i
  end

  def local_format(format)
    I18n.localize(@time, :format => format).gsub(DOUBLE_SPACE, SINGLE_SPACE).strip
  end
end