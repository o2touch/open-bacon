class TaskActionView < ActionView::Base
  include Rails.application.routes.url_helpers
  # include ApplicationHelper

  def default_url_options
     {host: 'mitoo.co'}
  end
end