class Api::V1::Users::FacebookRegistrationsController < Api::V1::ApplicationController

  skip_before_filter :authenticate_user!, only: [:create]
  skip_authorization_check only: [:create, :destroy]

  def create
    token = params[:facebook_token]
    render status: :bad_request, json: { message: "Missing credentials" } and return if token.blank?

    @graph = Koala::Facebook::GraphAPI.new(params[:facebook_token])
    @fb_data = @graph.get_object("me")  

    auth = Authorization.find_by_uid(@fb_data['id'])
    email_user = User.find_by_email(@fb_data['email'])

    # if we have an auth for that user
    if !auth.nil?
      # log in that mother fucker
      @user = auth.user
      auth.update_attributes!({token: token})

      #megahack
      follow_team(@user, params) if params[:save_type] == "FAFTTEAMFOLLOW"

    # if we have an email address for that user
    elsif !email_user.nil?
      # create an auth
      @user = email_user
      auth = create_auth(@user, @fb_data, token)

      #megahack
      follow_team(@user, params) if params[:save_type] == "FAFTTEAMFOLLOW"

    # else they must be new
    else
      # create an auth
      # so register that mother fucker.
      st = params[:save_type]
      st = UserInvitationTypeEnum::FACEBOOK if st.nil? # handle dickhead who arrive here by clicking login
      @user = create_user(@fb_data, st)
      auth = create_auth(@user, @fb_data, token)
      UserRegistrationsService.complete_registration(@user, st, params)
    end

    # grab the profile image in the background
    begin 
      FacebookProfileImageWorker.perform_async(@user.id, auth)
      Rails.logger.debug auth.to_yaml
    rescue
    end
    @user.ensure_authentication_token!
    sign_in @user, :bypass => true
    render template: "api/v1/m/sessions/create", formats: [:json], status: :ok
  end


  private

  # ****** HHHAAAAAAAAAACCCKKKKKKKKKKKK ************ 
  # This is basically stolen from faft_instructions_controller
  # we have to handle being able to follow a team AND login at the same time
  # as there is no difference between signing in with fb, and registering with it.
  # This DEFINITELY SHOULD BE REMOVED FROM HERE. TS
  def follow_team(user, params)
    team_id = params[:team_id]
    team = Team.find(team_id)

    # TODO: once the front end knows if a team exists, this bit can be removed. TS
    if !team.nil?
      authorize! :follow, team 
      
      return if team.followers.include? user

      team_role = TeamUsersService.add_follower(team, user, user)
      md = { team_id: team.id, processor: 'Ns2::Processors::TeamRolesProcessor' }
      AppEventService.create(team_role, user, "created", md)

      finished(:user_followed_team)
    end
  end


  def create_auth(user, data, token)
    auth_attrs = {
      :uid => data['id'],
      :token => token,
      :provider => "Facebook",
      :name => data['name'],
      :link => data['link']
    }
    user.authorizations.create(auth_attrs)
  end

  def create_user(data, save_type)
    name = data['name']
    country = GeographicDataUtil.new().country_from_ip(request.remote_ip) unless request.remote_ip.nil?
    email = data['email']
    password = Devise.friendly_token[0, 20]

    fb_tz = data['timezone']
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

  def update_user_profile(user, auth)
    pic_url = "http://graph.facebook.com/#{auth.uid}/picture?type=large"

    begin
      user.profile.profile_picture = open(pic_url)
      user.profile.save!
    rescue
      logger.info "Failed to update profile picture from fb for user #{user.id}"
    end    
  end
end
