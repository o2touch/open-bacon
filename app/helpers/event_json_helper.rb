module EventJsonHelper
  require 'set'

  # WARNING - These methods are tuned for performance. All changes should be tested and commited if and only if
  # they provide performance benefits across the application.

  def json_collection(events, user, mobile=false)
    ability = Ability.new(user)

    unless user.nil? || user.junior?
      children = Set.new(user.children.map {|x| x.id }) 
    else
      children = Set.new 
    end

    #TODO - Pass around a null user class to represent a guest. This cleans up a lot of nil checks!
    context_scope = BFFakeContext.new

  	data_hash = events.map do |event|
  		Rabl::Renderer.new(
			  mobile ? "api/v1/events/show_reduced_gamecard_mobile" : "api/v1/events/show_reduced_gamecard",  
        event,
				:view_path => 'app/views', 
				:format => 'hash',
        :object => event,
				:locals => { :user => user, :ability => ability, :children => children },
        :handler => :rabl,
        :scope => context_scope
			).render
    end

    data_hash.to_json
  end

  # WARNING - These methods are tuned for performance. All changes should be tested and commited if and only if
  # they provide performance benefits across the application.

  def event_data(event, user, ability, children)
    return { 
      "canEdit" => false, 
      "canRespond" => false 
    } if user.nil?

    parent = children.size > 0
    child_and_parent_tse_list = []

    event.cached_teamsheet_entries.each do |tse| 
      #TODO - We should use ability.rb however currently the below code is providing a performance benefit.
      
      if ((user.id == tse.user_id) || ( parent and (children.include?(tse.user_id)))) 
        child_and_parent_tse_list << { :id => tse.id, :user_id => tse.user_id, 
          :response_status => tse.response_status }
          #:profile_picture_small_url => tse.user.profile.profile_picture_small_url }
      end
    
      # Rabl::Renderer.new(
      #    "api/v1/teamsheet_entries/show_game_card",
      #     x,
      #     :view_path => 'app/views', 
      #     :format => 'hash',
      #     :object => x,
      #     :handler => :rabl,
      #   ).render 
      #
      # 0.030122599999999992 -> with Rabl::Renderer
      # 0.024241099999999998 -> with 2 loops
      # 0.017729299999999996 -> with 1 loop
    end

    # you cant edit fixtures. this also means you cant edit faft teams.
    can_edit = user.team_roles.any? { |x| event.fixture.nil? and (x.role_id == PolyRole::ORGANISER) and (x.obj_id == event.team_id) and (x.user_id == user.id) }

    permissions = { 
      "canEdit" => can_edit,
      "canRespond" => child_and_parent_tse_list.count > 0
    }

    return permissions, child_and_parent_tse_list
  end
end