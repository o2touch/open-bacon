module VanityUsernames
  def self.generate_cached_routes
    # Find all routes we have, take the first part (/xxx/) and remove some unwanted ones
    @cached_routes = Rails.application.routes.routes.each do |route|
      segs = route.segments.inject("") { |str, s| str << s.to_s }
      segs.sub! /^\/(.*?)\/.*$/, '\\1'
 
      # Some routes accept a :format parameter (ratings.:format).
      segs.sub! /\.:format$/, ''
      segs
    end
 
    # All possible controllers for /:controller/:action/:id route
    #@cached_routes += ActionController::Routing.possible_controllers.map do |c|
    #  # Use only the first path component for controllers with multiple path components
    #  c.sub /^(.*?)\/.*$/, '\\1'
    #end
    @cached_routes.uniq!
    # Remove routes whose first path component is a variable or wildcard
    @cached_routes.reject! { |route| route.to_s.starts_with?(':') or route.to_s.starts_with?('*') }
    # Remove the root route.
    @cached_routes.delete '/'
    @cached_routes
  end
  
  def self.username_is_valid_route?(username)
    not VanityUsernames.generate_cached_routes.include?(username)
  end
  
  def user_has_username?(user)
    !user.username.nil?
    #not FancyUrls.cached_routes.include?(username)
  end
 
  def self.cached_routes
    @cached_routes
  end
  
  def user_profile_url(person, options={})
    root_url + user_profile_path(person, options)
  end
  
  def user_profile_path(user, options={})
    username = username_for_user(user)
    raise ArgumentError, "No such user #{user.inspect}" unless username
 
    if user_has_username?(user) then
      short_profile_path options.merge(:username => username)
    else
      long_profile_path options.merge(:id => user.id)
    end
  end
 
  private 
  def username_for_user(user_or_id)
    return (if user_or_id.is_a?(User) then
      user_or_id.username
    else
      Rails.cache.get("username:#{user_or_id}") { User.find(user_or_id, :select => 'username').try(:username) }
    end)
  end
end