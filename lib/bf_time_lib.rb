class BFTimeLib
  class << self
    SINGLE_SPACE = ' '
    DOUBLE_SPACE = SINGLE_SPACE*2

    def utc_to_local(time, time_zone_str)
      tzi(time_zone_str).utc_to_local(time)
    end

    def local_to_utc(time, time_zone_str)
      tzi(time_zone_str).local_to_utc(time)
    end

    def time_zone_info(time_zone_str)
      TZInfo::Timezone.get(time_zone_str)
    end

    def tzi(time_zone_str)
      time_zone_info(time_zone_str)
    end

    def same_day?(a, b)
      #http://www.ruby-doc.org/stdlib-1.9.3/libdoc/date/rdoc/Date.html#method-i-3C-3D-3E
      time_a = a.respond_to?(:time) ? a.time : a
      time_b = b.respond_to?(:time) ? b.time : b
      time_a.utc.to_date === time_b.utc.to_date
    end

    def bf_format(time)
      t = I18n.localize(time, :format => :casual).gsub(DOUBLE_SPACE, SINGLE_SPACE)
      /,\s(.+)o/.match(t)
      # stip out the 'o' used as a marker and add a 'th', or whatever
      t.sub(/,\s(.+)o/, ",\s#{$1.to_i.ordinalize.to_s}").strip
    end
  end
end
