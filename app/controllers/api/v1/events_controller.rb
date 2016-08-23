class Api::V1::EventsController < Api::V1::ApplicationController
  include LocationHelper
  include EventJsonHelper


  skip_authorization_check only: [:index]
  # there is a public version of the event page
  skip_before_filter :authenticate_user!, only: [:show]

  def index
    resource = nil

    if !params[:user_id].nil?
    resource = User.find_by_id(params[:user_id])
    elsif !params[:team_id].nil?
      resource = Team.find_by_id(params[:team_id])
    end
    
    raise InvalidParameter.new, "no resource specified" if resource.nil?
    # need a generalised parameter validation solution.
    if params[:when].nil?
      @events = resource.events
    elsif params[:when] == "future"
      @events = resource.future_events
    elsif params[:when] == "past"
      @events = resource.past_events
    else
      raise InvalidParameter.new, "when is invalid"
    end

    @user = current_user
    
    user_cache_key = ""
    if (!current_or_guest_user.nil?)
      user_cache_key = current_or_guest_user.rabl_cache_key
    end

    # APP_VERSION_FIX: fix a bug in the first version of the app, where it always assumes
    #   the team that you're looking at is the home team.
    @app_fix_reverse_result = params[:app_version].nil?

    #SR - Surely we need to check if the current user can view the set of events. Need to address this soon.
    cache_key = "EventsFragment/#{user_cache_key}/EventsIndex/#{params[:when].to_s}/#{resource.cache_key}/#{resource.events_last_updated_at.utc.to_s(:number)}"

    @events_json = fetch_from_cache cache_key do
      json_collection(@events, @user, true)
    end

    render json: @events_json
  end

  def show
    @user = current_user
    @event = Event.find(params[:id])
    authorize! :read, @event

    # displaying, or not, of private details is handled in the view.
    # (though is perhaps shouldn't be??) T.S.

    # @user is read by the json rabl template to determine permissions.
    respond_with @event
  end


  def create
    user = current_user    
    user = create_guest_user if user.nil?

    authorize! :create, Event.new
    raise InvalidParameter.new, "" if params[:event].blank?
    raise InvalidParameter.new, "must provide team id" if params[:event][:team_id].nil?

    # now authorize on the team
    team = Team.find(params[:event][:team_id])
    authorize! :manage, team

    tenant = LandLord.new(team).tenant

    notify = params[:notify] == 1

    # build event ting
    params[:event][:title] = "Practice" if params[:event][:game_type] == GameTypeEnum::PRACTICE
    @event = user.events_created.build({
      title: params[:event][:title],
      game_type: params[:event][:game_type],
      location: location,
      response_required: params[:event][:response_required],
      status: EventStatusEnum::NORMAL,
      time_tbc: params[:event][:time_tbc]
    })
    @event.tenant = tenant
    @event.location = process_location_json(params[:event][:location])
    @event.last_edited = Time.now
    @event.time_zone = current_user.time_zone
    @event.time_local = params[:event][:time_local]
    # if a team has demo users event must be demo events.
    @event[:type] = "DemoEvent" if team.players.count > 1 && team.players.second.type == "DemoUser"
    @event.save!

    # get extra fields for the tenant.
    @event = set_tenanted_attrs(team, @event, params)

    TeamEventsService.add(team, @event, pusher=true, async=true) 

    # send to algolia (again)
    #  because first time it goes, it doesn't get the team info, as it is (and has to be)
    #  saved before it gets put on the team. Need to stop it being sent automatically.
    @event.index!

    # this was happening on event creation but now the team id is not set as part of event creation thus no notifications hit the team page
    @event.push_create_to_feeds

    # post to facebook
    FacebookService.post_organise_game_action(team, user, @event)

    # app event
    AppEventService.event_created(@event, current_user, { notify: true })

    team.goals.notify unless team.nil?

    render template: "api/v1/events/show", formats: [:json], locals: {:user => user}, location: api_v1_event_path(@event), status: :ok
  end

  def update
    @event = Event.find(params[:id])
    authorize! :manage_event, @event
    raise InvalidParameter.new, "" if params[:event].blank?


    # save some typing
    eps = params[:event]

    #because we dont use a state machine someone could create request that pass even though they move from one wrong state to another.
    #status is really a flag asking the api to move the event into a particular state.
    #each state has certain fields it needs to attempt transition.
    cancel_event = (eps[:status].to_i == EventStatusEnum::CANCELLED && 
                                  (@event.status == EventStatusEnum::NORMAL || @event.status == EventStatusEnum::POSTPONED))

    activate_event = (eps[:status].to_i == EventStatusEnum::NORMAL && 
                                  @event.status == EventStatusEnum::CANCELLED)

    postpone_event = (eps[:status].to_i == EventStatusEnum::POSTPONED && 
                                  @event.status == EventStatusEnum::NORMAL)

    reschedule_event = (eps[:status].to_i == EventStatusEnum::RESCHEDULED && 
                                  (@event.status == EventStatusEnum::POSTPONED || @event.status == EventStatusEnum::NORMAL))
    
    time_changed = false
    if eps[:time_local]
      time_changed = !TimeHelpers.compare_string_vs_object(eps[:time_local], @event.time_local)
    end

    # Some basic validation
    if reschedule_event && (eps[:time_local].nil? || !time_changed)
      raise InvalidParameter.new, "bad request for reschedule" #Should throw back something better
    end

    if postpone_event && (time_changed || (eps.has_key?(:time_local) && !eps[:time_local].nil?))
      raise InvalidParameter.new, "bad request for postpone" #Should throw back something better
    end

    location = process_location_json(eps[:location]) if eps.has_key?(:location)
    location = @event.location unless eps.has_key?(:location) # explicity set it to  nil

    new_attrs = {
        :title => eps[:title],
        :game_type => eps[:game_type],
        :reminder_updated => eps[:reminder_updated],
        :response_required => eps[:response_required]
    }
    new_attrs[:time_tbc] = eps[:time_tbc] if eps[:time_tbc]
    new_attrs[:location] = location

    #We should not set this on an update! However we shoud send time_local via the time field.
    #new_attrs[:time] = eps[:time] if eps[:time] 

    if eps[:time_local]
      new_attrs[:time_local] = eps[:time_local] 
    end

    new_attrs[:time_tbc] = true if postpone_event && !time_changed #hard override to prevent bad state plus should be backend calculated
    new_attrs[:status] = eps[:status].to_i if eps[:status]
    
    #This is an example of special logic which is related to the state of an event. It's so messy here. State machine is required.
    if reschedule_event
      new_attrs[:status] = 0 
      new_attrs[:time_tbc] = false
    end

    new_attrs[:last_edited] = Time.now
    new_attrs[:response_by] = eps[:response_by] if eps[:response_by]

    new_attrs.delete_if { |_, value| value.nil? } # We assume that we will never set something to nil

    # bypass the removing of nils above
    new_attrs[:location] = location

    @event.version_update do
      @event.update_attributes! new_attrs

      # get extra fields for the tenant.
      @event = set_tenanted_attrs(@event.team, @event, params)
      @event.save
    end


    # these blocks are actually state transition logic!
    # old. now hard coded. to remove. TS
    send_notifications = true

    # send emails if @event was just cancel_event and update feeds
    if cancel_event
      AppEventService.event_cancelled(@event, current_user, { notify: send_notifications })
      self.push_cancellation_to_feeds(@event)
    elsif postpone_event
      diff_map = self.event_diff(@event)
      # postpone_event is the state transition from normal to postoned
      # time_changed and postpone_event is the state transition from normal to postoned to rescheduled
      AppEventService.event_postponed(@event, current_user, { diff: diff_map, notify: send_notifications })
      self.push_postpone_notifications_to_feeds(@event, diff_map)
    elsif reschedule_event
      diff_map = self.event_diff(@event)
      AppEventService.event_rescheduled(@event, current_user, { diff: diff_map, notify: send_notifications })
      self.push_rescheduled_notifications_to_feeds(@event, diff_map)
      @event.reset_availability
    elsif activate_event # send emails if @event was just activate_event and update feeds
      AppEventService.event_activated(@event, current_user, { notify: send_notifications })
      self.push_activations_to_feeds(@event)
    else
      diff_map = self.event_diff(@event)
      AppEventService.event_updated(@event, current_user, { diff: diff_map, notify: send_notifications })
      self.push_update_to_feeds(@event, diff_map)
    end

    # update result if appropriate
    unless eps[:score_for].blank? || eps[:score_against].blank?
      result = @event.result || @event.build_result
      result.update_result(eps[:score_for], eps[:score_against], current_user)
    end

    #TODO : THIS IS WAY TOO MUCH INFORMATION RETURNED!
    render(template: "api/v1/events/show", locals: {:user => current_user}, formats: [:json], handlers: [:rabl], status: :ok)
  end

  def destroy
    @event = Event.find(params[:id])
    authorize! :manage_event, @event

    team = @event.team
    AppEventService.event_deleted(@event, current_user, { team_id: team.id })

    # I removed this as it seemed to trying to access a frozen hash in
    # whatever it was doing to merge the changes into a single version update
    # TS
    #@event.version_update do
      @event.destroy
    #end

    team.goals.notify unless team.nil?

    head :no_content
  end


  # handle any extra fields we need for this tenant
  def set_tenanted_attrs(team, event, params)
    # bare tests are giving me a double for team, so erroring in here...
    #  so I put this in to stop that happening, but I hate it. TS
    return event unless team.respond_to? :config

    efs = team.config.event_extra_fields

    if !efs.nil?
      efs.map{|e| e[:name]}.each do |f|
        event.tenanted_attrs[f] = params[:event][f]
      end
    end
    event
  end

  # This stuff should be in the model, or a service, but definitely not here! TS
  # SR - This is repeat code we can have in one place
  def push_update_to_feeds(event, diff_map)
    return if diff_map.length == 0

    activity_item = ActivityItem.new
    activity_item.subj = current_user
    activity_item.obj = event
    activity_item.meta_data = diff_map.to_json
    activity_item.verb = :updated
    activity_item.save!
    
    activity_item.push_to_activity_feed(event)
    activity_item.push_to_profile_feed(event.team) unless event.team.nil?   
  end

  def push_cancellation_to_feeds(event)
    activity_item = ActivityItem.new
    activity_item.subj = current_user
    activity_item.obj = event
    activity_item.verb = :cancelled
    activity_item.save!
    
    activity_item.push_to_activity_feed(event)
    activity_item.push_to_profile_feed(event.team) unless event.team.nil?   
  end

  def push_activations_to_feeds(event)
    activity_item = ActivityItem.new
    activity_item.subj = current_user
    activity_item.obj = event
    activity_item.verb = :activated
    activity_item.save!
    
    activity_item.push_to_activity_feed(event)
    activity_item.push_to_profile_feed(event.team) unless event.team.nil?   
  end

  def push_postpone_notifications_to_feeds(event, diff_map)
    activity_item = ActivityItem.new
    activity_item.subj = current_user
    activity_item.obj = event
    activity_item.meta_data = diff_map.to_json
    activity_item.verb = :postponed
    activity_item.save!
    
    activity_item.push_to_activity_feed(event)
    activity_item.push_to_profile_feed(event.team) unless event.team.nil?   
  end

  def push_rescheduled_notifications_to_feeds(event, diff_map)
    activity_item = ActivityItem.new
    activity_item.subj = current_user
    activity_item.obj = event
    activity_item.meta_data = diff_map.to_json
    activity_item.verb = :rescheduled
    activity_item.save!
    
    activity_item.push_to_activity_feed(event)
    activity_item.push_to_profile_feed(event.team) unless event.team.nil?   
  end

  def event_diff(event)
    #Rename this method to 'adaptor', put into a module

    #For DemoEvents lookup versioned_type == "Event"

    attr_diff = VestalVersions::Version.where(:versioned_id => event.id, :versioned_type => "Event", :tag => nil).order(:updated_at).last.modifications
    attr_diff = attr_diff.slice("location_id", "title", "game_type", "team_id", "time")

    diff_map = {}
    attr_diff.each do |attr, value| 
      old_value = value[0]
      new_value = value[1] 

      unless (old_value.blank? && new_value.blank?)
        if attr == "team_id"
          old_value = { :id => old_value, :value => Team.find(old_value).name } unless old_value.nil?
          if event.team.nil?
            new_value = nil
          else
            new_value = { :id => new_value, :value => event.team.name }
          end
        end
        if attr == "game_type"
          old_value = { :id => old_value, :value => Event.pretty_game_type(old_value) }
          new_value = { :id => new_value, :value => Event.pretty_game_type(new_value) }
        end
        if attr == "time"
          old_value = self.to_local_time(event, old_value)
          new_value = self.to_local_time(event, new_value)
        end
        if attr == "location_id"
          old_value = { :id => old_value, :value => Location.find(old_value).title } unless old_value.nil?
          new_value = { :id => new_value, :value => event.location.title } unless new_value.nil?
          new_value = new_value # either, what it just go set to, or nil
        end

        diff_map[attr] = [old_value, new_value]
      end
    end
    
    diff_map
  end

  def to_local_time(event, time)
    time_zone = nil
    time_zone = event.time_zone if !event.user.nil?
    tz = TZInfo::Timezone.get(time_zone) 
    return tz.utc_to_local(time)
  end
end