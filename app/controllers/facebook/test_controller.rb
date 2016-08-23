class Facebook::TestController < Facebook::FacebookController

  def index
    @access_token = @facebook_cookies["access_token"] if @facebook_cookies != nil
    @graph = Koala::Facebook::GraphAPI.new(@access_token)
  end
  
end