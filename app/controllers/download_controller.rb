class DownloadController < ApplicationController
  class InvalidParameter < StandardError; end

  # before_filter :authenticate_user!, :only => [:sign_up]
  skip_before_filter :set_locale, :set_timezone

  include AppStoreLinkHelper

  respond_to :json, only: [:send_install_link]

  rescue_from InvalidParameter, with: :unprocessable

  # Redirects user to relevant app store
  def app_store_redirect

    user_agent = UserAgent.parse(request.user_agent)

    # TODO: Metrics. Track download link clicked

    # iTunes App Store
    redirect_to itunes_url and return if !user_agent.platform.nil? && user_agent.platform.match(/iPhone|iPod|iPad/i)

    # Google Play Store
    redirect_to play_store_url and return if !user_agent.os.nil? && user_agent.os.match(/android/i)

    # Anything else
    redirect_to action: :download
  end

  # Displays download page
  def download
    
    if params.has_key? :confirm
      @team = Team.find_by_faft_id(params[:id]) unless params[:id].nil?

      render 'download_follow_flow', :layout => 'default'
      return
    end

    render 'download', :layout => 'default'
  end

  # Send Install link
  def send_install_link

    # raise InvalidParameter.new("No to parameter specified") if params[:token].nil?
    # raise InvalidParameter.new("No to parameter specified") if params[:time].nil?
    raise InvalidParameter.new("No to parameter specified") if params[:to].nil?

    to = params[:to]

    # TODO: Authenticate that it is coming from us
    # token_should_be = Digest::MD5.hexdigest(to + params[:time].to_s + "SUPERSECRETHASH")

    # if params[:token]!=token_should_be
    #   render status: :unprocessable_entity, json: {"message" => "Token invalid"} and return
    # end

    # Determine Country
    if !request.remote_ip.nil? && request.remote_ip!="0.0.0.0"
      location_info = GeoIP.new("#{Rails.root}/db/GeoIP.dat").country(request.remote_ip)
      location = location_info.country_code2

      GlobalPhone.default_territory_name = location.downcase if location != "--"
    end
    
    # Validate number
    number = GlobalPhone.parse(to)
    if !number.nil? && number.valid?
      TwilioService.send_download_link(number.international_string)
    else
      render status: :unprocessable_entity, json: {"message" => "Mobile number invalid"} and return
    end

    respond_with do |format|
      format.json { render status: :ok, json: { message: "Success" } }
    end
  end

  def unprocessable(exception)
    logger.info exception.message
    render status: :unprocessable_entity, json: { message: exception.message }
  end

end
