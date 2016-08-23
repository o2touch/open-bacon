module PusherHelper

  def pretty_truncate s, length = 30, ellipsis = '...'
    if s.length > length
      s.to_s[0..length].gsub(/[^\w]\w+\s*$/, ellipsis).rstrip
    else
      s
    end
  end

  def limit_bytesize(str, size)
    str.each_char.each_with_object('') do|char, result| 
      if result.bytesize + char.bytesize > size
        break result
      else
        result << char
      end
    end
  end

  def limit_bytesize_utf8(str, size)
    str.encoding.name == 'UTF-8' or raise ArgumentError, "str must have UTF-8 encoding"

    # Change to canonical unicode form (compose any decomposed characters).
    # Works only if you're using active_support
    str = str.mb_chars.compose.to_s if str.respond_to?(:mb_chars)

    # Start with a string of the correct byte size, but
    # with a possibly incomplete char at the end.
    new_str = str.byteslice(0, size)

    # We need to force_encoding from utf-8 to utf-8 so ruby will re-validate
    # (idea from halfelf).
    until new_str[-1].force_encoding('utf-8').valid_encoding?
      # remove the invalid char
      new_str = new_str.slice(0..-2)
    end
    new_str
  end

end