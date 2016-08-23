class Admin::AdminController < ApplicationController

  before_filter :authorise_admin
  layout "admin"
  
  def authorise_admin
    redirect_to :root if current_user.nil? || !current_user.role?(RoleEnum::ADMIN)
  end
  
  def become
    return unless current_user.role? RoleEnum::ADMIN # don't think we need this anyway TS
    sign_in(:user, User.find(params[:id]), :bypass => true)
    redirect_to root_url # or user_root_url
  end

  def ui
    # Leo, what layout do you want here??
    #render layout: 'layout'
  end
end