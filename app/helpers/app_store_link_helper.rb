module AppStoreLinkHelper

  def itunes_url(source=nil)
    options = source.nil? ? "" : "?utm_medium=web&utm_source=#{source}&utm_content=iphone"
    "http://itunes.com/apps/bluefields" + options
  end

  def play_store_url(source=nil)
    options = source.nil? ? "" : "&utm_medium=web&utm_source=#{source}&utm_content=android"
    "https://play.google.com/store/apps/details?id=com.bluefields.phonegap" + options
  end

  def show_app_download_link?
    return $rollout.active?(:download_app)
  end

end