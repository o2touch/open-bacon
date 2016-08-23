class ApplicationController < ActionController::Base
  ### protect_from_forgery
  ### skip_before_filter :verify_authenticity_token, :only => [:name_of_your_action]   
  include ApplicationHelper
  include SessionsHelper
  include CacheHelper
  include ApplicationHelper
  include AppStoreLinkHelper
  
  helper_method :current_or_guest_user
  helper_method :analytical
  helper_method :record_not_found
  
  before_filter :set_locale, :process_utm_data, :log_user_activity, :set_current_user_for_demo_objects, :set_exclude_from_analytics

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from CanCan::AccessDenied, with: :not_authorized
 
  def time
    start = Time.now
    yield
    Time.now - start
  end

  def set_hostname
    @hostname = request.host || "mitoo.co"
  end

  def set_locale  
    cookies[:locale] = params[:locale] if(!params[:locale].nil?)
    I18n.locale = cookies[:locale] || I18n.default_locale
  end 

  # Not very MVC, but see note in demo_user.rb
  def set_current_user_for_demo_objects
    DemoUser.current_user = current_user
  end

  # Handle CanCan Exceptions
  def not_authorized
    logger.info "ApplicationController - Access Denied"
    
    respond_to do |format|
      format.html{ render file: "public/401", :formats => [:html], :status => :unauthorized, :layout => false }
      format.json{ render :json => { message: "Unauthorized" }, status: :unauthorized }
    end
  end

  # Handle ActiveRecord::RecordNotFound
  # pretty much just display the search page.
  def record_not_found
    @user_json = {}.to_json
    @current_user_teams_json = [].to_json
    @current_user_leagues_json = [].to_json
    if !current_user.nil?
      @user_json = Rails.cache.fetch "#{current_user.rabl_cache_key}" do
        Rabl.render(current_user, "api/v1/users/show", view_path: 'app/views', :formats => [:json], :scope => BFFakeContext.new, :handlers => [:rabl]).html_safe
      end

      @current_user_teams_json = Rails.cache.fetch "#{current_user.rabl_cache_key}/CurrentTeams" do
        Rabl.render(current_user.teams, "api/v1/teams/index", view_path: 'app/views', :formats => [:json], :scope => BFFakeContext.new, :handlers => [:rabl]).html_safe
      end

      @current_user_leagues_json = Rabl.render(current_user.leagues_as_organiser, "api/v1/leagues/index", view_path: 'app/views', :formats => [:json], :scope => BFFakeContext.new, :handlers => [:rabl]).html_safe
    end
    
    @query = params[:q] unless params[:q].nil?

    # Jack's PLT optimisations
    @disable_facebook = true
    @disable_gmaps = true
    @body_class = "search-page"

    # tenant info
    @tenant = LandLord.default_tenant
    @tenant_json = Rabl.render(@tenant, 'api/v1/tenants/show', view_path: 'app/views',  formats: :json, locals: { page: "home" }).html_safe 

    respond_to do |format|
      format.html{ render "errors/error_404", status: :not_found, formats: [:html], layout: 'app_public' }
      format.json{ render :json => { message: "Not Found" }, status: :not_found }
    end
  end

  # This is used for split ab testing for people across sessions/machines
  def current_user_unique_id
    return current_user.id unless current_user.nil?
    request.session_options[:id]
  end
  
  # if user is logged in, return current_user, else return guest_user
  def current_or_guest_user
    Rails.logger.warn("current_or_guest_user is DEPRECATED - just use current_user")  
    current_user
  end

  # called (once) when the user logs in, insert any code your application needs
  # to hand off from guest_user to current_user.
  def logging_in        
    @user = User.find(current_user.id)
    sign_in @user

    redirect_to after_sign_in_path_for(@user)
  end
  
  # save utm tracking data
  def save_utm_data(user)
    if !session['utm_data'].nil?
      utm_data = session['utm_data']
      utm_data.user_id = user.id
      utm_data.save
      session['utm_data'] = nil
    end
  end

  # private

  # Performs a check that the subdomain is correct for the tenant
  # Used to perform a redirect_to(model, host: host)
  # @return [false, nil] if subdomain is correct
  # @return [true, host] if subdomain needs to change
  def change_domain_for_tenanted_model?(model)
    modules = model.class.ancestors.select {|o| o.class == Module}
    if !modules.include?(Tenantable)
      return [false, nil] 
    end

    tenant_host = model.get_tenant_domain
    if request.host != tenant_host
      return [true, tenant_host]
    end
    
    return [false, nil]
  end
  
  def parse_facebook_cookies 
    @facebook_cookies ||= Koala::Facebook::OAuth.new.get_user_info_from_cookie(cookies)
  end

  def log_user_activity
    # used to do metrics
  end

  # grab the 
  def process_utm_data
    return unless current_user.nil? && !session['utm_data']

    session['utm_data'] = UtmData.new({
      referer:  request.env["HTTP_REFERER"] || 'none',
      source:   params[:utm_source] || params[:bf_source],
      medium:   params[:utm_medium] || params[:bf_medium],
      term:     params[:utm_term],
      content:  params[:utm_content],
      campaign: params[:utm_campaign]
    })
  end

  # Performed on every request to exclude bots, mitoo ip address and ourselves from analytics
  def set_exclude_from_analytics
    @exclude_from_analytics = request.env['HTTP_USER_AGENT'].try(:match, /http/i) || request.remote_ip == "68.108.56.31" || (!current_user.nil? && current_user.email.match(/bluefields.com/i))
  end
end
