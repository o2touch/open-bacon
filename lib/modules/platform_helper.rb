class PlatformHelper

  # Return a hash containing the platform information
  # params - a hash of request parameters set by the controller
  def self.get_platform_from_params(params)

    # AppVersion is set by mobile apps
    if !params[:app_version].nil?
      return {
        :platform => "mobile",
        :app_version => params[:app_version],
        :app_tenant => params[:app_instance_id]
      }
    # If AppVersion is not set. It is a web request. A little tenuous
    else
      return {
        :platform => "web"
      }
    end
  end

end