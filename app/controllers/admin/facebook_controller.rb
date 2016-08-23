####
#
# FB LOGIN WAS DISABLED BEFORE OPEN SOURCING. RE-ENABLING SHOULD BE TRIVIAL
#
#####
class Admin::FacebookController < Admin::AdminController

  # before_filter :authenticate_user!, :only => [:sign_up]

  def index
    
    # @access_token = @facebook_cookies["access_token"] if @facebook_cookies != nil
    # graph = Koala::Facebook::GraphAPI.new(@access_token)
    # friends = graph.get_connections("me", "friends")
#     
    # @likes = []
    # @friends = []
    # size = 0;
    # friends.each do |friend|
#       
      # if(size > 100)
        # break
      # end
#       
      # likes = graph.get_connections(friend["id"], "likes");
#       
      # likes.each do |like|
#         
        # if(like['category']=="Amateur sports team" || like['category']=="Recreation/sports" || like['category'] == "Sports/Recreation/Activities" || like['category']== "Outdoor Gear/Sporting Goods" || like["category"] == "Sports League" || like["category"]=="Sports Venue" || like["category"]=="School Sports Team")
          # @likes << like
          # @friends << friend unless @friends.include?(friend)
        # end
      # end
#       
      # size += 1
    # end
        
    @is_connected = false
    
    if(current_user.authorizations.length == 1)
      @is_connected = true;
    end
  end
  
    
  def show
   
    # @oauth = Koala::Facebook::OAuth.new(Facebook::APP_ID, Facebook::SECRET, '')
    
    # @access_token = @facebook_cookies["access_token"] if @facebook_cookies != nil
    # graph = Koala::Facebook::GraphAPI.new(@oauth.get_app_access_token)
    
    # pages = graph.search("amateur", {:type => "page", :limit=>'5000'})
    # @asPage = []
    
    # pages.each do |page|
    #   logger.info page
    #   if(page["category"]=="Amateur sports team")
    #     pageObj = graph.get_connections(page["id"],"")
    #     @asPage << pageObj
    #   end
    # end  
  end
  
  def friendslikes
    
    @access_token = @facebook_cookies["access_token"] if @facebook_cookies != nil
    
    logger.info "ACCESS TOKEN IS " + @access_token.to_s
    
    if(@access_token.nil?)
      auth = current_user.authorizations.first
      @access_token = auth.token
    end
    
    graph = Koala::Facebook::GraphAPI.new(@access_token)
    friends = graph.get_connections("me", "friends")
    
    @likes = []
    @friends = []
    @friend_likes = {}
    size = 0;
    friends.each do |friend|
            
      logger.info friend
      
      likes = graph.get_connections(friend["id"], "likes");
      
      likes.each do |like|
        
        if(like['category'].downcase=="amateur sports team" || like['category'].downcase=="recreation/sports" || like['category'].downcase == "sports/recreation/activities" || like['category'].downcase== "outdoor gear/sporting goods" || like["category"].downcase == "sports league" || like["category"].downcase=="sports venue" || like["category"]=="School Sports Team")          
          @likes << like unless @likes.include?(like)
          @friends << friend unless @friends.include?(friend)
        end
      end
      
      size += 1
    end
    
    @total = size;
    
    # @friends.each do |friend|
#       
      # pic = graph.get_connections(friend["id"], "picture")
      # logger.info pic
      # friend["picture"] = pic
#       
    # end
  end
  
end