# *** must exist so we can iterate through it!

class TeamRole < ActiveRecord::Base
  attr_accessible :role_id, :team, :user, :team_id, :user_id
  
  belongs_to :user
  belongs_to :team
  
  validates :team, :presence => true
  validates :user, :presence => true
  #validates :role_id, :presence => true, 
  #  :inclusion => { :in => RoleEnum.values, :message => "%{value} is not a supported role" }

  after_create :create_activity
  after_save :touch_via_cache
  before_destroy do |x|
    x.touch_via_cache(Time.now)
    x.destroy_activity
  end

  def touch_via_cache(time=self.updated_at)
    time = time.utc
  	self.user.team_roles_last_updated_at = time unless self.user.nil?
  	self.team.team_roles_last_updated_at = time unless self.team.nil?
  	true
  end
  
  def self.is_player(user, team)
    TeamRole.exists? :role_id => TeamRoleEnum::PLAYER, :user_id => user.id, :team_id => team.id
  end
  
  def self.is_organiser(user, team)
    TeamRole.exists? :role_id => TeamRoleEnum::ORGANISER, :user_id => user.id, :team_id => team.id
  end

  def self.is_parent(user, team)
    TeamRole.exists? :role_id => TeamRoleEnum::PARENT, :user_id => user.id, :team_id => team.id
  end

  # Log activity with seprate Model
  def create_activity
    TeamRolesActivity.create!(:role_id => role_id, :user_id => user_id, :team_id => team_id) 
  end

  def destroy_activity
    tra = TeamRolesActivity.where(:role_id => self.role_id, :user_id => user_id, :team_id => team_id)
    tra.map(&:revoke)
  end
end
