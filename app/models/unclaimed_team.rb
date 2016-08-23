# nolonger used. TS
class UnclaimedTeam < Team
  include Configurable
  include Roleable
  
  roleable roles: [PolyRole::PLAYER, PolyRole::PARENT, PolyRole::ORGANISER, PolyRole::FOLLOWER]

  def add_organiser(user)
    raise 'Cannot add organisers to an unclaimed team.'
  end

  def add_player(user)
    raise 'Cannot add players to an unclaimed team.'
  end

  def add_parent(user)
    raise 'Cannot add parents to an unclaimed team.'
  end

  def open_invite_link
    ''
  end

  def created_by=(value)
    raise 'Cannot associate user as the founder of an unclaimed team.'
  end

  def goals
    @goals ||= GoalChecklist.new
  end
end
