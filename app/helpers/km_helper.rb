require 'base64'

module KmHelper

  # New method of tracking emails
  def track_email(recipient_id, email_name, data)
    kmid = ""
    kmid = "f6924c33b74ff6b4ec1e67c7f41d03b6" if Rails.env.production?
      
    return '' if email_name.nil? || recipient_id.nil?

    data = convert_url_params_to_hash(data) if data.is_a?(String)

    hash = {}
    hash["event"] = "Viewed Email #{email_name}".gsub("+"," ")
    hash["properties"] = data

    hash["properties"]["distinct_id"] = recipient_id
    hash["properties"]["email"] = recipient_id
    hash["properties"]["token"] = kmid
    hash["properties"]["time"] = Time.now.to_i if hash["time"].nil?

    img_url = get_img_path(hash)

    return "<img src=\"#{img_url}\"/>"
  end

  # Need to deprecate
  def get_img_html(title="", params="")

    kmid = ""
    kmid = "f6924c33b74ff6b4ec1e67c7f41d03b6" if Rails.env.production?
      
    return '' if title.nil? || params.nil?

    hash = {}
    hash["event"] = "Viewed Email #{title}".gsub("+"," ")
    hash["properties"] = convert_url_params_to_hash(params)

    hash["properties"]["distinct_id"] = get_distinct_id_from_params(params)
    hash["properties"]["Email"] = get_distinct_id_from_params(params)
    hash["properties"]["token"] = kmid
    hash["properties"]["time"] = Time.now.to_i if hash["time"].nil?

    img_url = get_img_path(hash)

    return "<img src=\"#{img_url}\"/>"
  end

  def get_img_path(data)
    encoded_data = encode_hash(data)
    "http://api.mixpanel.com/track/?data=#{encoded_data}&ip=1&img=1"
  end

  def encode_hash(hash)
    Base64.encode64(hash.to_json)
  end

  def get_distinct_id_from_params(params)
    params.split("&").each do |p|
      key,val = p.split("=")
      return key if val.nil?
    end
  end

  def convert_url_params_to_hash(params)
    hash = {}
    params.split("&").each do |p|
      key,val = p.split("=")
      hash[key] = val unless val.nil?
    end
    hash
  end

end
