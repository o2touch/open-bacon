class TeamRoleProcessor
  def initialize(name)
    @name = name
  end
  
  def process(notification_item)
    return false unless can_process?(notification_item)
    
    case notification_item.verb
    when VerbEnum::DESTROYED
      destroy_team_role(notification_item)
    when VerbEnum::CREATED
      create_team_role(notification_item)
    end

    true
  end

  private
  def can_process?(item)
    #Performance critical code block
    item.obj_type == PolyRole.name and [VerbEnum::DESTROYED, VerbEnum::CREATED].include?(item.verb)
  end

  def extract_team_and_user(notification_item)
    team = Team.find(notification_item.meta_data[:team_id])
    user = User.find(notification_item.meta_data[:user_id])
    return team, user
  end

  def destroy_team_role(notification_item)
    case notification_item.meta_data[:role_id]
    when PolyRole::PLAYER, PolyRole::PARENT
      user_removed_from_team(notification_item)
    when PolyRole::ORGANISER
      organiser_role_revoked_from_user(notification_item) 
    end
  end
  
  def create_team_role(notification_item)
    case notification_item.meta_data[:role_id]
    when PolyRole::ORGANISER
      organiser_role_granted_to_user(notification_item)
    end
  end

  def user_removed_from_team(notification_item)
    team, user = extract_team_and_user(notification_item)
    UserMailer.delay.user_removed_from_team(user, team)
  end

  def organiser_role_revoked_from_user(notification_item)
    team, user = extract_team_and_user(notification_item)
    UserMailer.delay.organiser_role_revoked_from_user(user, team)
  end

  def organiser_role_granted_to_user(notification_item)
    team, user = extract_team_and_user(notification_item)
    UserMailer.delay.organiser_role_granted_to_user(user, team)
  end
end
