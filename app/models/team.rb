# This gets messy as fuck further down.
# Could do with all the uses of it's shitty small methods tracking down, and
#  either having the methods removed, cleaned up, or commented. TS
class Team < ActiveRecord::Base
  include RedisModule
  include CacheHelper
  include Messageable
  include TeamUserModule
  include TeamSearch # Team search index
  include Tenantable # Tenanted methods
  include Configurable # settings magic
  include Roleable # user roles

  delegate :url_helpers, to: 'Rails.application.routes'
  
  # divisions
  # helper method below, so can just call team.divisions to get the current division seasons
  has_many :team_division_season_roles
  has_many :division_seasons, through: :team_division_season_roles, conditions: { team_division_season_roles: { role: TeamDSRoleEnum::MEMBER }}
  has_many :pending_division_seasons, through: :team_division_season_roles, conditions: { team_division_season_roles: { role: TeamDSRoleEnum::PENDING }}

  belongs_to :club

  has_many  :events

  belongs_to :profile, :class_name => "TeamProfile"
  belongs_to :created_by, :polymorphic => true
  has_many :activity_item_links, :as => :feed_owner
  has_many :profile_feed_activity_items, :source => :activity_item, :through => :activity_item_links

  # Deprecated. User powertokens going forwards
  has_many  :team_invites

  # team roles
  #has_many :team_roles, created by Roleable
  has_many :players, source: :user, through: :team_roles, conditions: { poly_roles: { role_id: PolyRole::PLAYER }}
  has_many :parents, source: :user, through: :team_roles, conditions: { poly_roles: { role_id: PolyRole::PARENT }}
  has_many :organisers, source: :user, through: :team_roles, conditions: { poly_roles: { role_id: PolyRole::ORGANISER }} 
  has_many :followers, source: :user, through: :team_roles, conditions: { poly_roles: { role_id: PolyRole::FOLLOWER }}
  has_many :associates, source: :user, through: :team_roles, uniq: true
  has_many :members, source: :user, through: :team_roles, uniq: true, conditions: { 
    :poly_roles => { :role_id => [PolyRole::PLAYER, PolyRole::PARENT, PolyRole::ORGANISER] }
  }

  # attrs 
  attr_accessible :created_by_id, :created_by_type, :slug
  attr_accessible :name, :demo_mode, :source, :source_id

  serialize :settings, Hash

  # validations
  validates :name, presence: true

  # callbacks
  before_validation :set_default_slug
  before_create :generate_uuid

  # Enable Configurable Settings
  configurable settings_hash: :configurable_settings_hash, parent: :configurable_parent

  # Specify the roles allowed for this model
  roleable roles: [PolyRole::PLAYER, PolyRole::PARENT, PolyRole::ORGANISER, PolyRole::FOLLOWER]


  # DO NOT USE, will be removed soon!
  # This is only to stop old things breaking! TS
  def self.find_by_faft_id(id)
    return nil if id.nil?
    self.where(source_id: id, source: "faft").first
  end

  # This shit is all TOTALLY WACK, should not be used, and should be refactored
  #  out of existance. TS  
  def self.find_by_mitoo_id(id)
    
    result = self.where(source_id: id, source: "mitoo")
    raise ActiveRecord::RecordNotFound if result.empty? || result.nil?

    result.first
  end
  # used to stop us indexing the old, fucked mitoo teams.
  def is_old_mitoo?
    self.source == "old_mitoo"
  end
  # precautionary measures
  def faft_id
    self.source_id
  end
  # precautionary measures
  def faft_id=(value)
    self.source_id = value
  end


  # return the current division seasons
  def divisions
    self.division_seasons.select(&:current_season)
  end

  # Hmm. not sure about this method. Do we use it?? TS
  def founder
    return self.created_by if self.created_by_type == User.name
    return self.created_by.organisers.first if self.created_by_type == League.name
    return User.find(self.created_by_id) if self.created_by_id && self.created_by_type.nil?
    nil
  end

  # All this fucking insanity needs sorting, innit. 
  #  If anyone has to touch this stuff (and therefore understand it), refactor to
  #  use configurable (ie. config stuff) instead. TS
  def league_config(division=nil)
    #This check on divsions is very bad.
    return {} if self.divisions.count == 0
    division = division == nil ? self.divisions.first : division
    division_id = division.id.to_s 

    save_league_config = false
    if self.settings[LeagueConfigKeyEnum::KEY].nil? 
      self.settings[LeagueConfigKeyEnum::KEY] = {}
      save_league_config = true
    end
    if self.settings[LeagueConfigKeyEnum::KEY][division_id].nil?
      self.settings[LeagueConfigKeyEnum::KEY][division_id] = {} 
      save_league_config = true
    end

    self.save if save_league_config

    all_settings = self.settings[LeagueConfigKeyEnum::KEY][division_id]
    all_settings = division.league.league_config.merge(all_settings) unless division.league.nil?
    all_settings
  end
  def team_config
    if self.settings[TeamConfigKeyEnum::KEY].nil?
      self.settings[TeamConfigKeyEnum::KEY] = {}
      self.save
    end

    self.settings[TeamConfigKeyEnum::KEY]
  end
  # settings helper methods
  def league_managed_roster?
    # TODO: FIX THIS!!!! TS
    true
    # THIS IS WACK
    #lmr = self.league_config[LeagueConfigKeyEnum::LEAGUE_MANAGED_ROSTER]
    #!lmr.nil? && lmr
  end

  # DEPRACATED - do not use, check the config directly instead.
  #    This method exists because it's replacing an old shit one.
  def is_public?
    !self.config.nil? && self.config.team_public == true # comparison incase it isn't set
  end

  # used to get events for a team, when a divisions is published. Seems a bit strange to me!
  def updated_events
    events = self.future_events.select do |event|
      self.schedule_last_sent.nil? || (!event.last_edited.nil? && event.last_edited > self.schedule_last_sent)
    end

    events
  end

  # could use the above method for this, but this should be faster.
  def schedule_updates?
    return true if self.schedule_last_sent.nil?
    self.future_events.each do |event|
      return true if !event.last_edited.nil? && event.last_edited > self.schedule_last_sent
    end
    false
  end

  # DEPRECATED
  def faft_team?
    return self.source=="faft"
  end
  def alien_team?
    !self.source.nil?
  end

  def leagues
    division_seasons.map{ |d| d.league }.uniq.compact
  end

  # league convenience methods
  def user_is_primary_league_admin?(user)
    primary_league.has_organiser? user
  end

  def in_league?(league) #change to static on league object
    return false if league.nil?
    league.teams.include? self
  end

  def in_division_season?(division_season)
    return false if division_season.nil?
    division_season.teams.include? self
  end

  # this is all mental. TS
  def primary_division
    return divisions.first if league?
    NullDivision.new
  end
  def league?
    self.divisions.count > 0
  end
  def primary_league
    # 10000 is the id of the non-existant league that we assign to all comp divisions
    return NullLeague.new if primary_division.nil? || primary_division.is_a?(NullDivision)
    return NullLeague.new if primary_division.league_id == 10000
    primary_division.league
  end

  def junior?
    self.profile and (self.profile.age_group != AgeGroupEnum::ADULT)
  end
  
  def rabl_cache_key
    key_extension = self.updated_at ? "#{self.events_last_updated_at.utc.to_s(:number)}/#{self.team_roles_last_updated_at.utc.to_s(:number)}" : "none"
    profile_cache_key = self.profile ? "#{self.profile.cache_key}" : "none"
    "#{self.cache_key}/#{profile_cache_key}/#{key_extension}"
  end
  
  def events_last_updated_at
    fetch_from_cache "#{self.cache_key}/events_last_updated_at" do
      self.updated_at ? self.updated_at : Time.now
    end
  end

  def events_last_updated_at=(value)
    Rails.cache.write "#{self.cache_key}/events_last_updated_at", value
  end

  def cached_events
    TeamProfile
    Event
    DemoEvent
    cache_key = "#{self.cache_key}/events/#{self.events_last_updated_at.utc.to_s(:number)}"
    
    begin
      return fetch_from_cache cache_key do
        self.events(true)
      end
    rescue
      Rails.cache.delete cache_key
      return self.events(true)
    end
  end

  def team_roles_last_updated_at
    fetch_from_cache "#{self.cache_key}/team_roles_last_updated_at" do
      self.updated_at ? self.updated_at : Time.now
    end
  end

  def team_roles_last_updated_at=(value)
    Rails.cache.write "#{self.cache_key}/team_roles_last_updated_at", value
  end

  def cached_team_roles
    TeamProfile
    PolyRole
    cache_key = "#{self.cache_key}/#{self.team_roles_last_updated_at.utc.to_s(:number)}/TeamRole"

    fetch_from_cache cache_key do
      self.team_roles(true)
    end
  end

  def events_this_week
    self.cached_events.find_all { |e| (!e.time.nil? && (e.time > Time.now && e.time <= TimeEnum::END_OF_THIS_WEEK)) }.sort_by(&:time)
  end
  
  def events_next_week
    self.cached_events.find_all { |e| (!e.time.nil? && (e.time > TimeEnum::END_OF_THIS_WEEK) && (e.time <= TimeEnum::END_OF_NEXT_WEEK)) }.sort_by(&:time)
  end
  
  def events_upcoming
    self.cached_events.find_all { |e| (!e.time.nil? && e.time > TimeEnum::END_OF_NEXT_WEEK) }.sort_by(&:time)
  end
  
  def future_events
    self.cached_events.find_all { |e| (!e.time.nil? && e.time > Time.now) }.sort_by(&:time)
  end
  alias_method :upcoming_events, :future_events
  
  def past_events
    self.cached_events.find_all { |e| (!e.time.nil? && e.time <= Time.now && e.time >= 3.months.ago) }.sort_by(&:time)
  end

  def locations
    self.cached_events.map { |e| e.location }.uniq.compact
  end

  # Takes an array of user ids and only returns the players which are in the team
  def get_players_in_team(user_ids)
    self.players.where(:id => user_ids)
  end

  # to ensure rails routing magic works for subclasses (ie. DemoTeam)
  def self.inherited(child)
    child.instance_eval do
      def model_name
        Team.model_name
      end
    end
    super
  end

  def demo_players
    self.players(true).select { |x| x.type == "DemoUser" } 
  end

  def active_players
    self.players.reject { |m| !m.is_registered? || m.is_a?(DemoUser) }
  end
  
  def goals
    unless @goals
      @goals = GoalChecklist.new
      @goals.add_item(TeamCreatedOneEvent.new(self))
      @goals.add_item(TeamAddedSchedule.new(self))
      @goals.add_item(TeamEnroledFourPlayers.new(self)) 
    end
    @goals
  end

  def open_invite_link
    route = url_helpers.team_path(self) + "#open-invite"
  
    token = PowerToken.find_by_route(route)
    token = PowerToken.create!(route: route) if token.nil?
    return url_helpers.power_token_url(token)
  end
  
  # call back
  def set_default_slug
    if self.slug.blank? && !self.name.blank?
      base_slug = self.name.downcase.gsub('&','and').gsub('/','').strip.gsub(' ', '-').gsub('--','-').gsub(/[^\w-]/, '').gsub('--','-')
      self.slug = base_slug
    end
  rescue Exception => e
    puts e.to_yaml
  end

  def nuke
    self.team_division_season_roles.delete_all
    self.team_roles.delete_all
    self.events.delete_all
    self.profile.destroy
    self.activity_item_links.delete_all
    self.team_invites.delete_all

    destroy
  end

  private
  
  def active_member_ids
    cache_key = "#{self.cache_key}/#{self.team_roles_last_updated_at.utc.to_s(:number)}/TeamRole/ActionableMembers"
    
    fetch_from_cache cache_key do
      member_ids = self.parent_ids | self.organiser_ids
      member_ids = member_ids | self.player_ids unless self.junior?
      member_ids.uniq
    end
  end

  # could definitely go in a helper somewhere more general
  def generate_uuid
    self.uuid = SecureRandom.uuid
  end
end
