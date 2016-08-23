class Api::V1::ActivityItemsController < Api::V1::ApplicationController
  skip_authorization_check only: [:create, :show, :destroy, :index, :mobile_index]

  def index
    owner = find_owner
    
    raise InvalidParameter.new, "Invalid owner" if owner.nil?

    feed_type = params[:feed_type].to_s
    raise InvalidParameter.new, "Invalid feed type" unless ['profile', 'newsfeed', 'activity'].include?(feed_type)
    
    authorize! :read_private_details, owner

    @activity_items = owner.get_mobile_feed(feed_type, nil, nil, 20, nil)[0].select { |activity_item| can? :view, activity_item }

    respond_with @activity_items
  end

  def mobile_index
    #fixed page size for cacheing.
    #dont know last page. front end check for empty set. not uncommon.
    #by default the feed puts emphasis on starred items.
    #you can filter the feed in only 3 ways.
    #:modifier_type => [:message, :star, :vanilla]
    #:starred => [:first, :all]
    #:feed_type => [:profile, :newsfeed, :activity]
    #:time_offset => nil
    #ask jack to change starred item update pusher channel to :profile since we need to convert whole system across.

    time_offset = params[:offset].nil? ? Time.now.to_i : params[:offset].to_i
    raise InvalidParameter.new, "Invalid offset" if time_offset == 0

    owner = find_owner
    raise InvalidParameter.new, "Invalid owner" unless owner.is_a?(Team) || owner.is_a?(Event)
    
    authorize! :read_private_details, owner

    #Hard coded params
    feed_type = params[:feed_type].to_s
    raise InvalidParameter.new, "Invalid feed type" unless ['profile', 'newsfeed', 'activity'].include?(feed_type)

    page_size = 5
    starred = params[:starred_type]
    raise InvalidParameter.new, "Invalid star type" unless [nil, 'first', 'all'].include?(starred)

    modifier_type = params[:modifier_type]
    raise InvalidParameter.new, "Invalid mod type" unless [nil, 'message', 'vanilla'].include?(modifier_type)
    
    @activity_items, feed = owner.get_mobile_feed(feed_type, starred, modifier_type, page_size, time_offset)

    previous_page = ""
    next_page = ""

    unless feed.empty? || @activity_items.empty?
      first = feed.first[1].to_i
      last = feed.last[1].to_i

      owner_id_hash_key = owner.is_a?(Team) ? :team_id  :  :event_id 

      o_params = params.dup
      o_params = o_params.merge({ :offset => last, :controller => params[:controller], :action => 'mobile_index'})

      next_page =  url_for(o_params )
      previous_page =  nil #url_for :controller => params[:controller], :action => 'mobile_index', :offset => first, :team_id => owner.id

      next_page = nil if (@activity_items.count < page_size) || (feed.last[1] == feed.first[1])


      @activity_items.pop unless next_page.nil? #last item should be part of next page
    end

    render(template: "api/v1/activity_items/paged_index", formats: [:json], handlers: [:rabl], status: :ok, :locals => { :previous_page => previous_page, :next_page => next_page })
  end

  def update
    @activity_item = ActivityItem.cache_find_by_id(params[:id])
    #authorize! :update, @activity_item #Checks if this is an EventMessage being updated and for the correct team
      
    #Move logic into something smarter that is returned from the messageable  
    @team = @activity_item.obj.messageable_type == Team.name ? @activity_item.obj.messageable : @activity_item.obj.messageable.team

    #Do we require 2 checks?
    authorize! :manage, @team 

    unless params['meta_data'].nil? or params['meta_data']['starred'].nil?
      params['meta_data']['starred_at'] = Time.now
    end

    meta_data = nil
    unless params['meta_data'].nil? or params['meta_data'].empty?
      if @activity_item.meta_data.nil?
        meta_data = params['meta_data']
      else
        meta_data = JSON.parse(@activity_item.meta_data)
        meta_data = meta_data.merge(params['meta_data'])
      end
      @activity_item.meta_data = meta_data.to_json
      @activity_item.save!

      #SR - Another bad block of code caused by inconsistant feed names.
      feed_type = :activity
      if @activity_item.obj.messageable.class == Team
        feed_type = :profile
      end

      @activity_item.push_to_redis(@activity_item.obj.messageable, feed_type) unless @activity_item.fetch_from_redis(@activity_item.obj.messageable, feed_type).nil?
    end
    render(template: "api/v1/activity_items/show", formats: [:json], handlers: [:rabl], status: :ok)
  end

  # Not implemented (obvs)
  # If you implement you MUST remove the action from skip_authorization_check above!

  def create
    head :not_implemented
  end

  def show
    if params[:id]
      @activity_item = ActivityItem.find_by_id(params[:id].to_i)
    else 
      @activity_item = ActivityItem.where(:obj_type => params[:obj_type], :obj_id => params[:obj_id].to_i).first
    end

    raise ActiveRecord::RecordNotFound if @activity_item.nil?
    authorize! :view, ActivityItem
    render(template: "api/v1/activity_items/show", formats: [:json], handlers: [:rabl], status: :ok)
  end

  def destroy
    head :not_implemented
  end

  private 

  def find_owner  
    params.each do |name, value|  
      if name =~ /(.+)_id$/ and ['team', 'event', 'user', 'demo_event', 'division'].include?($1)
        match = $1
        match = "division_season" if match == "division"
        return match.classify.constantize.find_by_id(value)  
      end  
    end  
    nil  
  end 
end