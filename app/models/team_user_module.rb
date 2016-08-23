module TeamUserModule
  def add_organiser(user)
    team_role = self.add_member(PolyRole::ORGANISER, user)
    self.organisers(true)
    team_role
  end

  def add_player(user)
    team_role = self.add_member(PolyRole::PLAYER, user)
    self.players(true)
    team_role
  end

  def add_parent(user)
    team_role = self.add_member(PolyRole::PARENT, user) 
    self.parents(true)
    team_role
  end

  def add_follower(user)
    team_role = self.add_member(PolyRole::FOLLOWER, user)
    self.followers(true)
    team_role
  end

  def remove_player(user)
    self.revoke_role(PolyRole::PLAYER, user)
    self.players(true)
  end

  def remove_organiser(user)
    self.revoke_role(PolyRole::ORGANISER, user)
    self.organisers(true)
  end

  def remove_follower(user)
    self.revoke_role(PolyRole::FOLLOWER, user)
    self.followers(true)
  end

  def remove_parent(user)
    self.revoke_role(PolyRole::PARENT, user)
    self.parents(true)
  end

  def has_associate?(user)
    self.associate_ids.include?(user.id)
  end

  def has_active_member?(user)
    active_member_ids.include?(user.id)
  end

  def has_member?(user)
    self.cached_member_ids.include?(user.id)
  end

  def has_parent?(user)
    self.cached_parent_ids.include?(user.id)
  end

  def has_player?(user)
    self.cached_player_ids.include?(user.id)
  end

  def has_organiser?(user)
    self.cached_organiser_ids.include?(user.id)
  end

  def has_follower?(user)
    self.cached_follower_ids.include?(user.id)
  end

  def revoke_role(role, user)
    #We have dupes in our DB :-(
    user.team_roles.where(:role_id => role, obj_type: "Team", :obj_id => self.id).map(&:destroy)
    self.team_roles_last_updated_at = Time.now
  end

  def cached_member_ids
    Rails.cache.fetch "#{members_cache_key}:member_ids" do
      self.member_ids
    end
  end

  def cached_parent_ids
    Rails.cache.fetch "#{members_cache_key}:parent_ids" do
      self.parent_ids
    end
  end

  def cached_organiser_ids
    Rails.cache.fetch "#{members_cache_key}:organiser_ids" do
      self.organiser_ids
    end
  end

  def cached_player_ids
    Rails.cache.fetch "#{members_cache_key}:player_ids" do
      self.player_ids
    end
  end

  def cached_follower_ids
    Rails.cache.fetch "#{members_cache_key}:follower_ids" do
      self.follower_ids
    end
  end

  def members_cache_key
    "#{self.cache_key}:#{self.team_roles_last_updated_at}:members_cache_key"
  end
  
  def add_member(role, user)
    raise 'Team must be persisted before creating team roles.' if self.id.nil?

    team_role = nil
    # Create team role
    if !PolyRole.exists?(role_id: role, user_id: user.id, obj_type: "Team", obj_id: self.id)
      team_role = self.team_roles.create!(:role_id => role, :user => user, :obj => self) 
      self.team_roles_last_updated_at = Time.now
      self.save
    end
    team_role
  end
end