module MobileDeviceHelper

  def is_mobile_device?
    return (is_android_device? || is_iphone_device?)
  end

  def is_android_device?
    user_agent = UserAgent.parse(request.user_agent)
    return !user_agent.os.nil? && user_agent.os.match(/android/i) { true } || false
  end

  def is_iphone_device?
    user_agent = UserAgent.parse(request.user_agent)
    return !user_agent.os.nil? && user_agent.os.match(/iphone|ipod/i) { true } || false
  end

  def is_ipad_device?
    user_agent = UserAgent.parse(request.user_agent)
    return !user_agent.os.nil? && user_agent.os.match(/ipad/i) { true } || false
  end

end