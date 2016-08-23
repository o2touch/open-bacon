class Facebook::FacebookController < ActionController::Base
  ### protect_from_forgery
  
  layout 'default'
  before_filter :parse_facebook_cookies
  
  def index
    if(!current_user.nil? && !@facebook_cookies.nil?)
      redirect_to events_path
      return
    end    
  end
  
  def parse_facebook_cookies
    @facebook_cookies ||= Koala::Facebook::OAuth.new.get_user_info_from_cookie(cookies)
  end
  
end