class Users::SessionsController < Devise::SessionsController  
  
  # GET /resource/sign_in
  def new

    @tenant = LandLord.new(request.subdomain).tenant

    resource = build_resource
    clean_up_passwords(resource)
    respond_with(resource, serialize_options(resource))
  end

  def create
    guest = current_or_guest_user    
    resource = warden.authenticate!(:scope => resource_name, :recall => "users/sessions#failure")    
    return sign_in_and_redirect(resource_name, resource)
  end
  
  def sign_in_and_redirect(resource_or_scope, resource=nil)    
    scope = Devise::Mapping.find_scope!(resource_or_scope)
    resource ||= resource_or_scope    
    
    sign_in(scope, resource) unless warden.user(scope) == resource

    respond_to do |format|
      format.html { redirect_to after_sign_in_path_for(resource) }
      format.json { render json: {:success => true, :redirect => stored_location_for(scope) || after_sign_in_path_for(resource)}}
    end
  end

  def after_sign_in_path_for(resource)
    forced_return_path = request.headers['ReturnTo']
    path = forced_return_path || "/?skip_geo=true"
    
    if resource.is_a? User
      # send to demo team
      demo_team = resource.teams_as_organiser.find { |x| x.demo_mode == 1 }
      path = "/teams/#{demo_team.id}" if demo_team

      # send to league
      if resource.leagues_as_organiser.size >= 1
         path = league_path(resource.leagues_as_organiser.first)
      end

      # send to metrics dashboard
      if resource.tenant_roles.count > 0
        tenant = resource.tenant_roles.first.obj
        path = "/tenants/#{tenant.subdomain}"
      end
    end

    store_location = session[:return_to]
    clear_stored_location
    (store_location.nil?) ? path : store_location.to_s
  end


  def failure
    respond_to do |format|
      format.html { render :action => 'new' }
      format.json { render json: {:success => false, :errors => ["Login failed."]}, :status => :unauthorized }
    end
  end 
end