class EventsController < ApplicationController  
  #load_and_authorize_resource  
  before_filter :redirect_if_guest, :only => :confirm  
    
  rescue_from ActiveRecord::RecordNotFound, :with => :rescue_not_found

  # Render team page if access is denied
  rescue_from CanCan::AccessDenied, :with => :no_permissions
  
  def index  
    @events = []
    calName = "Mitoo"
    
    if(!current_user.nil?)
      @events = current_user.future_events
    elsif(!params[:uuid].nil?)
      team = Team.find_by_uuid(params[:uuid])

      if !team.nil?
        @events = team.events
        
        userId  = params[:user_id] if !params[:user_id].nil?
        
        calName = team.name

      end
    end
  
    cal = RiCal.Calendar do |c|
      
      c.add_x_property 'X-WR-CALNAME', calName
      
      @events.each do |e|
        c.event do |ev|
          ev.summary e.title.to_s
          ev.description e.title.to_s
          
          if !e.time.nil?
            ev.dtstart e.time.to_datetime
            ev.dtend e.time.advance(:hours=>1).to_datetime
          end
          
          ev.location e.location.title unless e.location.nil?
          ev.url = url_for(e)
          # ev.status = "NEEDS-ACTION"
          ev.add_comment("More info at " + url_for(e))
          #add_attendee "john.glenn@nasa.gov"
          #alarm do
            #description "Segment 51"
          #end
        end
      end
    end
   
    respond_to do |format|
      format.html { redirect_to "/dashboard" }
      format.json { render(template: "events/index", formats: [:json], handlers: [:rabl])}
      format.ics { send_data(cal.export, :filename=>"mycal.ics", :disposition=>"inline; filename=mycal.ics", :type=>"text/calendar")}
    end
  end

  # GET /events/1
  # GET /events/1.json
  def show   
    # before_filer initialize event    
    # if logged in user, requesting a normal event
    if !params[:id].nil? && !current_user.nil?
      @event = Event.find(params[:id])
      authorize! :read, @event

      @page_type = "logged-in"

    # if responding to an invite link
    elsif !params[:token].nil?
      player_teamsheet_entry = TeamsheetEntry.find_by_token(params[:token])
      @page_type = "invite-link"
      
      # redirect if no TSE
      if(player_teamsheet_entry.nil?)
        redirect_to '/'
        return
      end
      
      responding_user = player_teamsheet_entry.user 
      responding_user = player_teamsheet_entry.user.parents.first if(player_teamsheet_entry.user.junior?)
      
      # find event and player from TSE
      @event = player_teamsheet_entry.event

      response_str = nil
      response_str = params[:response].downcase if !params[:response].nil?

      # set the response if it is 'yes' or 'no'
      if !response_str.nil? && (response_str=="yes" || response_str == "no")
        response_status = AvailabilityEnum::NOT_RESPONDED
        if params[:response] == "yes"         
          response_status = AvailabilityEnum::AVAILABLE
        elsif params[:response] == "no"
          response_status = AvailabilityEnum::UNAVAILABLE
        end
        
        invite_response = TeamsheetEntriesService.set_availability(player_teamsheet_entry, response_status)
        
        if !invite_response.nil?
          player_teamsheet_entry.send_push_notification 

        end

        # Sign-in user
        sign_in responding_user, :bypass => true

        # authorize! :read, @event

        redirect_to @event and return
      end

      # If response string is "k"
      if response_str == "k"
        session[:return_to] = event_path(@event)
        sign_in responding_user, :bypass => true
        # redirect_to invite_link_path(params[:token],"k")
        # return
      end

      # Only here if response string is not recognised
      # session[:return_to] = event_path(@event)
      # sign_in responding_user, :bypass => true
      # redirect_to invite_link_path(params[:token],"k")
      redirect_to event_path(@event) and return


    # if there is an open_invite_link
    elsif !params[:open_invite_link].nil?
      # find the event using that
      @event = Event.find_by_open_invite_link(params[:open_invite_link])
      authorize! :read, @event

      # if they are the owner of the game, redirect them to the event page proper 
      if current_user && @event.user_id == current_user.id
        redirect_to @event
        return
      end
      
      # if they are already invited redirect them to the event page proper
      if current_user && @event.teamsheet_entries.find_by_user_id(current_user.id)
        redirect_to @event
        return
      end
      
      @page_type = "open-invite"

    # you can only get here if you don't supply an :id, in which case the request
    # wouldn't be routed here..
    # if the user has events display their first one       
    elsif !current_user.nil? && !current_user.events_created[0].nil?
      @event = current_user.events_created[0]
       authorize! :read, @event

      @page_type = "logged-in"


    # if there is no user, but is an event id, show the public version
    elsif current_user.nil? && !params[:id].nil?
      @event = Event.find(params[:id])
       authorize! :read, @event

      @page_type = "public-intro"


    # else, fuck them off. 
    else
      redirect_to home_path
      return
    end

    return if @event.nil?

    # Check if at right domain
    q = ""
    u = URI.parse(request.url)
    q += "?" + u.query unless u.query.nil?

    change_domain, host = change_domain_for_tenanted_model?(@event)
    redirect_to event_url(@event, host: host) + q and return if change_domain

    # get the user
    @user = current_user
    
    # Set Facebook Object
    @fb_headprefix = "prefix=\"og: http://ogp.me/ns# fb: http://ogp.me/ns/fb# #{Facebook::NAMESPACE.to_s}: http://ogp.me/ns/fb/#{Facebook::NAMESPACE.to_s}#\""
    
    # fb open graph shit
    set_meta_tags :open_graph => {
      :title => @event.game_type_string,
      :description => @event.title,
      :determiner => "a",
      :type  => "#{Facebook::NAMESPACE.to_s}:game",
      :url   => url_for(@event),
      :image => request.protocol + request.host_with_port + ActionController::Base.helpers.image_path('/fb/gameicon.jpg')
    }
    
    set_meta_tags "bluefields:event_time" => l(@event.time)

    contains_no_demo_players = !@event.cached_teamsheet_entries.any? { |x| x.user.type == "DemoUser" }
    if @user and contains_no_demo_players and !@user.get_setting(:completed_event_page)
      @user.update_setting(:completed_event_page, true)
      @user.save
      @user.goals.notify
    end

    # tenant info
    @tenant = LandLord.new(@event).tenant
    @tenant_json = Rabl.render(@tenant, 'api/v1/tenants/show', view_path: 'app/views',  formats: :json, locals: { page: "event" }).html_safe 

    @global_application_context = BFFakeContext.new

    if !current_user.nil?
      @teams_json = Rabl.render(current_user.teams, "api/v1/teams/index", view_path: 'app/views', :formats => [:json], :scope => @global_application_context, :handlers => [:rabl])
      @leagues_json = Rabl.render(current_user.leagues_as_organiser, "api/v1/leagues/index", view_path: 'app/views', :formats => [:json], :scope => @global_application_context, :handlers => [:rabl])
      @user_json = Rabl.render(@user, "api/v1/users/show", view_path: 'app/views', :formats => [:json], :handlers => [:rabl])
    end

    @event_json = Rabl.render(@event, "api/v1/events/show", view_path: 'app/views', :locals => {:user => @user}, :formats => [:json], :scope => @global_application_context, :handlers => [:rabl])
    respond_to do |format| 
      format.html { render }
      format.json { render(template: "events/show", formats: [:json], handlers: [:rabl])}
    end    
  end
  
  def check_permissions
    authorize! :create, @event
  end
  
  def invite
    @event = Event.find(params[:id])
    @teamsheet_entries = @event.teamsheet_entries
    @teamsheet_entry = TeamsheetEntry.new    
  end

  def no_permissions
    redirect_to team_path(@event.team) unless @event.team.nil?
  end
  
  protected
  def rescue_not_found
    respond_to do |format|
      format.html { render :file => 'public/404', :status => :not_found, :layout => false }
      format.json { head :not_found }
    end
  end
  
  private
  def redirect_if_guest
    logger.info "REDIRECT IF GUEST"
    if current_user.role?("Guest")
      redirect_to guest_registration_path
      return false      
    end   
  end
  
end