class Users::RegistrationsController < Devise::RegistrationsController
  #before_filter :check_permissions, :only => [:new, :create, :cancel]
  skip_before_filter :require_no_authentication, only: [:new]
 
  def check_permissions
    authorize! :create, resource
  end
  
  def new    

    set_meta_tags :noindex => true
  end
  
  def guest_registration
    @user = current_or_guest_user
    
    @user.roles.delete(Role.cache_find_by_name("Invited"))
    @user.roles << Role.cache_find_by_name("Registered")
    
    # password verification?
    @user.email = params[:email]
    @user.password = params[:password]
  end
  
  def update
    if params[resource_name][:password].blank?
      params[resource_name].delete(:password)
      params[resource_name].delete(:password_confirmation) if params[resource_name][:password_confirmation].blank?
    end
    # Override Devise to use update_attributes instead of update_with_password.
    # This is the only change we make.
    if resource.update_attributes(params[resource_name])
      set_flash_message :notice, :updated
      # Line below required if using Devise >= 1.2.0
      sign_in resource_name, resource, :bypass => true
      redirect_to after_update_path_for(resource)
    else
      clean_up_passwords(resource)
      render_with_scope :edit
    end
  end
  
  protected
  def after_update_path_for(resource)
    event_path(resource.events_created[0])
  end
    
end