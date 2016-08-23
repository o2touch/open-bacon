class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook    
    oauthorize "Facebook"
  end
  
  private
  
  def oauthorize(kind)
    # find, or create a user object 
    @user = find_for_ouath(kind, request.env["omniauth.auth"], current_user)

    # some dickhead just clicked log in with fb, but they don't have an account,
    # and haven't been invited yet.
    redirect_to signup_path and return if @user.nil?

    # Is this used?? TS
    flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => kind

    # sign the user in
    sign_in @user

    # TODO: come up with a more robost post signin redirect solution
    #       non-fb sign in uses after_sign_in_path_for(resource), but that
    #       needs a few changes before it's extending it to be used here aswell. TS
    redirect_path = request.env['omniauth.origin']
    # if they're signing up send them else where...
    if request.env['omniauth.params']['save_type'] == 'SIGNUPFLOW'
      team = @user.teams.first
      redirect_path = team_path(team) + "#schedule"
    end

    respond_to do |format|
      format.html { redirect_to redirect_path || root_path }
      format.json { render json: @user, :status => 200 }
    end
=begin
  rescue Exception => e

    logger.info "EXCEPTION"
    logger.info e.to_yaml 

    respond_to do |format|
      format.html { redirect_to root_path }
      format.json { render json: {:error => true}, :status => 500 }
    end
=end
  end


  # TODO: Refactor this... It got big and messy. TS
  def find_for_ouath(provider, access_token, signed_in_resource=nil)
    # uid is facebook id
    uid = access_token[:uid]
    email = access_token['extra']['raw_info']['email']
    # attributes for the authorization model
    auth_attrs = {
      :uid => uid,
      :token => access_token['credentials']['token'],
      :provider => "Facebook",
      :name => access_token['info']['name'],
      :link => access_token['extra']['raw_info']['link']
    }

    # The case that a signed in user wants to link their account. (ie. accepting an invitation)
    user = signed_in_resource
    # The case that a user has already signed up via/linked to fb.
    user = find_for_oauth_by_uid(uid) if user.nil?
    # The case that an existing (non-fb connected) user signs in with fb.
    user = find_for_oauth_by_email(email) if user.nil?

    # if we don't have a user at this point, check to see if there is a
    # save_type, if there isn't, the user just clicked on log in with fb
    # without actually having an account... So fuck them off to signup flow
    save_type = request.env['omniauth.params']['save_type']
    return nil if user.nil? && save_type.nil?

    # Else make a new user, innit.
    user = create_user_from_access_token(access_token, save_type) if user.nil?
    
    auth = Authorization.find_by_uid(uid)
    # new authorization
    if auth.nil?
      auth = user.authorizations.create(auth_attrs)

      # if it's a new signup
      save_utm_data(user) unless save_type.nil?
    # attempted new auth, but fb account linked to different fb account
    elsif !auth.nil? && auth.user_id != user.id
      # TODO: SHIT IS FUCKED (fb account already linked to different bf account)
    # just logging in
    else
      auth.update_attributes!(auth_attrs)
    end

    if !save_type.nil?
      params = request.env['omniauth.params']
      UserRegistrationsService.complete_registration(user, save_type, params)
    end

    update_profile_pic(user, access_token)

    user
  end
   

  # get the user using their fb id
  def find_for_oauth_by_uid(uid)
    auth = Authorization.find_by_uid(uid.to_s)
    return auth.user unless auth.nil?
    nil
  end
  

  # get the user using their email address
  def find_for_oauth_by_email(email)
    User.find_by_email(email)
  end


  def create_user_from_access_token(data, save_type)
    logger.debug(data.to_yaml)
    logger.debug(cookies['timezone'])
    name = data["extra"]["raw_info"].first_name + " " + data["extra"]["raw_info"].last_name
    country = GeographicDataUtil.new().country_from_ip(request.remote_ip) unless request.remote_ip.nil?
    email = data['extra']['raw_info']['email']
    password = Devise.friendly_token[0, 20]

    fb_tz = data["extra"]["raw_info"]["timezone"]
    time_zone = TimeZoneEnum[fb_tz.to_i] unless fb_tz.blank?
    time_zone = request.cookies['timezone'] if time_zone.nil?
    time_zone = TimeZoneEnum[0] if time_zone.nil?

    user = User.create!({
      name: name,
      email: email,
      country: country,
      time_zone: time_zone,
      invited_by_source: save_type,
      password: password,
      password_confirmation: password
    })

    user
  end


  def update_profile_pic(user, data)
    pic_url = data[:info][:image]
    return if pic_url.blank?

    pic_url = pic_url.split("=")[0] << "=large"
    begin
      user.profile.profile_picture = open(pic_url)
      user.profile.save!
    rescue
      logger.info "Failed to update profile picture from fb for fb_id #{data[:uid]}"
    end
  end
end