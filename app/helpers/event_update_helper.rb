module EventUpdateHelper
  require 'time'

  PRETTY_ATTRIBUTE_MAP = {
    'location' => 'Location',
    'title' => 'Title',
    'time' => 'Time',
  }

  def pretty_event_atributes(updates)
    keys = PRETTY_ATTRIBUTE_MAP.keys
    pretty_updates = {}

    updates.each do |key, value| 
      key = key.to_s
      if keys.include?(key)
        pretty_updates[PRETTY_ATTRIBUTE_MAP[key]] = value[1]
      end
    end

    if pretty_updates.has_key?('Time')
      time = pretty_updates['Time']
      pretty_updates['Time'] = BFTimeLib.bf_format(time)
    end
    pretty_updates
  end
end
