class Admin::FeedController < ApplicationController
  layout "admin"

  def index
    @user = current_or_guest_user
    @activities = @user.activities
    @ddd = User.find(13)
    @others = @ddd.activities
  end

end