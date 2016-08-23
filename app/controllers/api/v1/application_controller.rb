class Api::V1::ApplicationController < Api::ApplicationController
  class InvalidParameter < StandardError; end

  check_authorization
  prepend_before_filter :get_app_version_header_value
  prepend_before_filter :get_app_instance_token
  prepend_before_filter :get_header_token
	before_filter :authenticate_user!

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :unprocessable
  rescue_from ActionController::RoutingError, with: :routing_error
  rescue_from CanCan::AccessDenied, with: :unauthorized
  rescue_from InvalidParameter, with: :unprocessable
  rescue_from InviteToTeamError, with: :unprocessable
  rescue_from TeamRoleError, with: :unprocessable
  rescue_from ExistingRoleError, with: :conflict
  #rescue_from TeamDivisionSeasonRoleError, with: :unprocessable

  respond_to :json


  # an action routes sends shit to when it maches nothing else.
  # seems wierd that we need this, but I can't be fucked to check. TS
  def raise_routing_error
    raise ActionController::RoutingError.new("Not Found")
  end


  protected

  # so we can time some methods
  def time
    start = Time.now
    yield
    Time.now - start
  end


  private 

  # This overides devise's method (which returns a 302).
  def authenticate_user!
  	unauthorized and return unless user_signed_in?
  end



  # handle exceptions

  def conflict(exception)
    logger.info exception.message
    message = exception.message || "Conflict"
    render status: :conflict, json: { message: message }
  end

  def record_not_found(exception)
    logger.info exception.message
    message = exception.message || "No Such Record"
    render status: :not_found, json: { message: message }
  end

  def routing_error(exception)
    # on the off-chance someone accidentally goes to /api/NOT_A_PAGE 
    respond_to do |format|
      # TODO: This errors with: No route matches {:controller=>"home"}
      format.html { redirect_to :root }
      format.json { render status: :not_found, json: { message: "No Such Route" } }
    end
  end

  def unauthorized
  	render status: :unauthorized, json: { message: "Unauthorized" }
  end

  def unprocessable(exception)
    logger.info exception.message
    render status: :unprocessable_entity, json: { message: exception.message }
  end



  # Grab headers and stick them in the params, for easy access in contrs

  # put the header token into a param for devise
  def get_header_token
    if auth_token = params[:auth_token].blank? && request.headers["X-AUTH-TOKEN"]
      params[:auth_token] = auth_token
    end
  end

  # so we can vary functionality based on the app version
  def get_app_version_header_value
    if auth_token = request.headers["X-APP-VERSION"]
      params[:app_version] = auth_token
    end
  end

  # so we know which app we're dealing with (ie. mitoo, o2 touch etc.)
  def get_app_instance_token
    if app_instance_token = request.headers["X-APP-ID"]
      
      app = MobileApp.find_by_token(app_instance_token)
      raise "no such app id #{app_instance_token}" if app.nil?

      params[:app_instance_id] = app.id
    else
      #params[:app_instance_id] = MobileApp.find_by_name("mitoo").id
      # had to do it this shit way, because the above makes capybara tests fail
      #  (I think because teardown starts before the test has fully finished)
      params[:app_instance_id] = 1 # mitoo app id
    end
  end

  # This is used to determine the platform information. It's used (in
  # controllers) to pass through to tracking services
  def get_platform
    PlatformHelper.get_platform_from_params(params)
  end
end