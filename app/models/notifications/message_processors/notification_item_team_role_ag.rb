#TODO Rename this class
class NotificationItemTeamRoleAg < AggregateMessageProcessor 
  def initialize(team_id)
    @team_id = team_id
  end

  def can_process?(item)
    #Performance critical code block
    team_id = item.meta_data[:team_id]

    case item.obj_type
    when PolyRole.name
      team_id = item.obj.team_id if item.obj
    when TeamInvite.name
      team_id = item.obj.team_id
    else 
      false
    end  

    team_id == @team_id and [VerbEnum::DESTROYED, VerbEnum::CREATED].include?(item.verb)
  end

  def process(items)
    team = Team.find(@team_id)

    items = transform_notification_items_to_json(items)
    
    rank_map = build_rank_map(items)
          
    #Extract data from rank map
    removed_organisers = extract_data_for_team_role(rank_map, PolyRole::ORGANISER, :destroyed)
    invited_organisers = extract_data_for_team_role(rank_map, PolyRole::ORGANISER, :created)
    removed_players = extract_data_for_team_role(rank_map, PolyRole::PLAYER, :destroyed)
    invited_players = extract_data_for_team_role(rank_map, PolyRole::PLAYER, :created)

    #Mark items as processed
    mark_processed(items.map {|x| x[:id] })

    team.organisers.each do |organiser|
      TeamOrganiserMailer.delay.aggregated_team_roles(@team_id, organiser.id, removed_organisers, removed_players, invited_organisers, invited_players)
    end

    true
  end

  private
  def extract_data_for_team_role(rank_map, team_role, verb)
    data = [] | rank_map.map do |key, value| 
      if key[1] == team_role
        case verb
        when :destroyed
          value[1] if value[0] < 0 
        when :created
          value[1] if value[0] > 0
        end
      end
    end
    
    data.compact!
    data
  end

  def build_rank_map(items)
    #TODO Rewrite using OpenStruct.new
    rank_map = {}

    items.each do |x|
      rank_item_tuple = nil
      if rank_map.has_key?([x[:user_id], x[:role_id]])
        rank_item_tuple = rank_map[[x[:user_id], x[:role_id]]]
      else
        rank_map[[x[:user_id], x[:role_id]]] = [0, nil]
        rank_item_tuple = rank_map[[x[:user_id], x[:role_id]]]
      end

      rank_item_tuple[1] = x
      if x[:verb].to_s == :destroyed.to_s
        rank_item_tuple[0] = rank_item_tuple[0] - 1
      elsif x[:verb].to_s == :created.to_s
        rank_item_tuple[0] = rank_item_tuple[0] + 1
      end
    end

    #Discard items where there is no change to report
    rank_map.reject! {|key, value| value[0] == 0}

    rank_map
  end

  def transform_notification_items_to_json(items)
    json_items = items.map do |item|
      case item.obj_type
      when PolyRole.name
        extract_team_role_data(item)
      when TeamInvite.name
        extract_team_invite_data(item)
      end
    end

    json_items.compact!
    json_items.sort_by! { |x| x[:created_at] }
  end

  def extract_team_invite_data(item)
    { 
      :id => item.id,
      :user_name => item.obj.sent_to.name,
      :user_id => item.obj.sent_to.id,
      :role_id => PolyRole::PLAYER,
      :created_at => item.obj.created_at,
      :verb => item.verb
    }
  end

  def extract_team_role_data(item)
    { 
      :id => item.id,
      :user_name => item.meta_data[:user_name],
      :user_id => item.meta_data[:user_id],
      :role_id => item.meta_data[:role_id],
      :created_at => item.meta_data[:created_at],
      :verb => item.verb
    }
  end

  def mark_processed(ids)
    #TODO Something is not quite right about this being here
    NotificationItem.where(:id => ids).update_all({:processed_at => Time.now})
  end
end