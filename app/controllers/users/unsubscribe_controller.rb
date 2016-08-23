class Users::UnsubscribeController < ApplicationController
  #before_filter :check_permissions, :only => [:new, :create, :cancel]
  skip_before_filter :require_no_authentication, only: [:new]
   
  def show    
    set_meta_tags :noindex => true

    if current_user.nil?
      render 'logged_in', :layout => 'default'
      return
    end

    current_user.unsubscribe

    render :layout => 'default'
  end
    
end