# *** must exist so we can iterate through it!
class LeagueRole < ActiveRecord::Base
  attr_accessible :role_id, :league, :user
  
  belongs_to :user
  belongs_to :league

  after_save :touch_via_cache
  before_destroy { |x| x.touch_via_cache(Time.now) }

# stolen from team roles, probably useful, so not deleted
  def touch_via_cache(time=self.updated_at)
    time = time.utc
    #self.user.league_roles_last_updated_at = time unless self.user.nil?
    #self.league.league_roles_last_updated_at = time unless self.league.nil?
    return true
  end
  
  def self.is_organiser?(user, league)
    return false if user.nil? or league.nil?
    LeagueRole.exists? :role_id => LeagueRoleEnum::ORGANISER, :user_id => user.id, :league_id => league.id
  end
end
