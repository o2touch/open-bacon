class Event < ActiveRecord::Base
  include RedisModule
  include CacheHelper
  include Messageable
  include Tenantable # tenanting shit
  include EventSearch # search index config

  versioned :dependent => :tracking, :if => :create_new_version?

  belongs_to :user 
  alias_method :organiser, :user

  belongs_to :team
  # access through #fixture method below.
  has_one :home_fixture, class_name: "Fixture", foreign_key: :home_event_id
  has_one :away_fixture, class_name: "Fixture", foreign_key: :away_event_id

  has_one :open_graph_event
  
  has_many :teamsheet_entries
  has_many :users, :through => :teamsheet_entries
  has_many :event_reminders_queue_items
  has_many :reminders, :class_name => "InviteReminder", :through => :teamsheet_entries, :order => 'created_at ASC'

  belongs_to :location
  
  has_many :activity_items, :as => :obj
  has_many :activity_item_links, :as => :feed_owner
  
  has_one :result, :class_name => "EventResult"
  
  # game_type 0=game, 1=practice, 2=event
  attr_accessible :game_type
  
  # invite_type 0=private, 1=open
  attr_accessible :invite_type
  
  attr_accessible :status
  
  attr_accessible :time, :time_zone, :time_local, :title,  :response_by, :response_required, :reminders_start, :reminder_updated
  attr_accessible :open_invite_link, :team_id, :result_id, :user, :last_edited, :location, :location_id, :time_tbc 

  # loads of bullshit
  serialize :tenanted_attrs, Hash
    
  before_create :create_open_invite_link
  before_create :default_values
  
  #after_create :push_create_to_feeds  Tim broke this by not specifiying the team id at the time of event creation.
  
  after_save :touch_via_cache
  before_destroy { |x| x.touch_via_cache(Time.now) }

  #validate :timeInfuture # what the fuck is this?? there isn't a method. TS
  validate :only_one_fixture
  validates :title, presence: true, length: { maximum: 70 }
  validates :game_type, presence: true, inclusion: GameTypeEnum.values
  validates :status, presence: true, inclusion: EventStatusEnum.values
  
  # Scopes
  scope :past, ->{ where("time < ?", Time.now).order("time DESC") }
  scope :future, ->{ where("time > ?", Time.now).order("time ASC") }

  def only_one_fixture
    if !self.home_fixture.nil? && !self.away_fixture.nil?
      errors.add(:away_fixture, "can only have home fixture or away fixture")
    end
  end

  def fixture
    self.home_fixture || self.away_fixture
  end

  def home_or_away
    return "home" unless self.home_fixture.nil?
    return "away" unless self.away_fixture.nil?
    return nil
  end

  # return the tenanted attrs hash for this event, but filtered by the extra
  #  attrs allowed for this object's tenant (just in case)
  def tenanted_attrs_by_tenant
    return {} if self.team.nil? || self.team.config.event_extra_fields.nil?

    attrs = {}
    team.config.event_extra_fields.each do |f|
      attrs[f[:name]] = self.tenanted_attrs[f[:name]]
    end

    attrs
  end
 
  def version_update(&block)
    begin
      self.transaction do
        @version_lock_on = false
        self.merge_version do
          yield
        end
      end
    ensure
      @version_lock_on = true
    end
  end

  def touch_via_cache(time=self.updated_at)
    @bftime = nil
    time = time.utc
    self.organiser.events_last_updated_at = time unless self.organiser.nil?
    self.users.each {|invitee| invitee.events_last_updated_at = time }
    
    unless self.team.nil?
      self.team.followers.each {|follower| follower.events_last_updated_at = time} 
      self.team.events_last_updated_at = time
    end

    self.set_feed_last_updated_at(:activity, Time.now)
    return true
  end

  def rabl_cache_key
    key_extension = self.updated_at ? "#{self.teamsheet_entries_last_updated_at.utc.to_s(:number)}" : "none"
    team_cache_key = self.team ? self.team.cache_key : "none"
    result_cache_key = self.result ? self.result.cache_key : "none"
    user_cache_key = self.user ? self.user.cache_key : "none"
    "#{self.cache_key}/#{team_cache_key}/#{user_cache_key}/#{result_cache_key}/#{key_extension}"
  end

  def teamsheet_entries_last_updated_at
    fetch_from_cache "#{self.cache_key}/teamsheet_entries_last_updated_at" do
      self.updated_at ? self.updated_at : Time.now
    end
  end

  def teamsheet_entries_last_updated_at=(value)
    Rails.cache.write "#{self.cache_key}/teamsheet_entries_last_updated_at", value
  end

  def cached_teamsheet_entries
    TeamsheetEntry
    InviteReminder
    InviteResponse
    cache_key = "#{self.cache_key}/#{self.teamsheet_entries_last_updated_at.utc.to_s(:number)}/TeamsheetEntry"
    fetch_from_cache cache_key do
      self.teamsheet_entries.find(:all, :include => [:invite_responses, :reminders])
    end
  end

  def graceful_time_zone
    self.time_zone.nil? ? self.user.time_zone : self.time_zone
  end

  def time_local
    BFTimeLib.utc_to_local(self.time, self.graceful_time_zone)
  end

  def time_local=(time_str)
    self.time = BFTimeLib.local_to_utc(Time.parse(time_str), self.graceful_time_zone)
    self.save
  end

  def bftime(recalc=false)
    @bftime = BFTime.new(self.time, self.graceful_time_zone, self.time_tbc) if not @bftime || recalc
    @bftime
  end

  def is_cancelled?
    self.status == EventStatusEnum::CANCELLED
  end

  def is_postponed?
    self.status == EventStatusEnum::POSTPONED
  end

  # was the event reactivated in the last change to it?
  def was_reactivated?
    return false if self.status == 1 || self.version == 1
    VestalVersions::Version.find_by_versioned_id(self.id).modifications.has_key?('status')
  end

  def should_notify?
    self.type != "DemoEvent" and self.response_required and !self.is_cancelled? and !self.is_postponed?
  end
  
  def push_create_to_feeds
    activity_item = ActivityItem.new
    activity_item.subj = self.user
    activity_item.obj = self
    activity_item.verb = :created
    activity_item.save!
    
    activity_item.push_to_profile_feed(self.user)
    activity_item.push_to_profile_feed(self.team)    
    activity_item.push_to_activity_feed(self)

    unless self.instance_of? DemoEvent 
      activity_item.push_to_newsfeeds    
    end

    activity_item
  end
  
  def all_users
    return invitees
  end

  def invitees
    self.cached_teamsheet_entries.map{ |tse| tse.user } | [self.user]
  end

  def is_invited?(invitee)
    # SLOW SLOW SLOW
    # faster = self.cached_users & [invitee.id]
    self.cached_teamsheet_entries.any? { |tse| tse.user == invitee } 
  end

  def teamsheet_entry_for_user(invitee)
    self.cached_teamsheet_entries.find { |tse| tse.user == invitee } 
  end
  
  def game_type_string(capitalise=false, determiner=false)
    Event.pretty_game_type(self.game_type, capitalise, determiner)
  end

  def self.pretty_game_type(game_type, capitalise=false, determiner=false)
    game_type_strings = [
      "game",
      "practice",
      "event"
    ]
    s = game_type_strings[game_type]
    if capitalise
      s = s.capitalize
    end

    if determiner
      determiner_str = "a"
      determiner_str = "an" if game_type==2
      s = determiner_str + " " + s
    end

    s
  end
  
  def add_open_graph(fbid)
    self.open_graph_event = OpenGraphEvent.create(:fbid => fbid) if(!fbid.nil? && self.open_graph_event.nil?)
  end
  
  def default_values
    self.game_type ||= 0
    self.status ||= 0
    self.response_by ||= 1
  end
  
  def create_open_invite_link
    token_length = 16      
    self.open_invite_link = rand(36**token_length).to_s(36)
  end
  
  # used to give summary data in-app, with loading all tses
  def availability_summary #This should be changed to availability_summary_count
    unavailable = 0
    available = 0
    awaiting = 0

    self.cached_teamsheet_entries.each do |tse|
      if tse.response_status == 0
        unavailable += 1
      elsif tse.response_status == 1
        available += 1
      elsif tse.response_status == 2
        awaiting += 1
      end
    end

    { unavailable: unavailable, available: available, awaiting: awaiting }
  end

  # used to give summary data in-app, with loading all tses
  def availability_summary_obj #This should be changed to availability_summary
    unavailable = []
    available = []
    awaiting = []

    self.cached_teamsheet_entries.each do |tse|
      if tse.response_status == 0
        unavailable << tse.user
      elsif tse.response_status == 1
        available << tse.user
      elsif tse.response_status == 2
        awaiting << tse.user
      end
    end
    { unavailable: unavailable, available: available, awaiting: awaiting }
  end

  # used to give summary data in-app, with loading all tses
  def check_in_summary
    checked_in = 0
    not_checked_in = 0

    self.cached_teamsheet_entries.each do |tse|
      checked_in += 1 if tse.checked_in
      not_checked_in += 1 unless tse.checked_in
    end

    { checked_in: checked_in, not_checked_in: not_checked_in }
  end

  #SR - This logic is repeated time and time again!
  def unavailable_players
    players = []
    self.cached_teamsheet_entries.each do |teamsheet_entry|
      if teamsheet_entry.response_status == InviteResponseEnum::UNAVAILABLE
        players << teamsheet_entry.user
      end
    end
    players
  end

  
  def time_of_last_reminder
    max_time = nil
    self.cached_teamsheet_entries.each do |teamsheet_entry|
      teamsheet_entry.reminders.each do |reminder|
        if max_time.nil? || reminder.created_at > max_time
          max_time = reminder.created_at
        end
      end
    end
    max_time
  end
  
  def reset_availability
    self.cached_teamsheet_entries.each do |tse|
      TeamsheetEntriesService.reset_availability(tse)
      tse.send_push_notification("update")
    end
    self.teamsheet_entries_last_updated_at = Time.now
  end
  
  def teamsheet_entries_awaiting
    self.cached_teamsheet_entries.select { |teamsheet_entry| teamsheet_entry.response_status == 2 }
  end

  def teamsheet_entries_available(include_creator=true)
    self.teamsheet_entries_filter_by_response_status([AvailabilityEnum::AVAILABLE], include_creator)
  end
  
  def teamsheet_entries_filter_by_response_status(statuses, include_creator=true)
    self.cached_teamsheet_entries.select { |tse| statuses.include?(tse.response_status) && (!include_creator || tse.user != self.user) }
  end
  
  def has_details_set
    !self.game_type.nil? && !self.title.nil?
  end
  
  def has_players_invited
    return self.cached_teamsheet_entries.size
    #return TeamsheetEntry.count(:conditions => ['event_id = ? AND user_id != ?', self.id, self.organiser.id]) > 0
  end
  
  def as_json(options={})
    super(options.merge({:methods => [:availability_summary, :has_details_set, :has_teamsheet_set], :include => [:teamsheet_entries,:team]}))
  end

  # Check if is a league event
  def is_league_event?
    !self.fixture.nil?
  end

  def demo_event?
    false
  end

  # to ensure rails routing magic works for subclasses (ie. DemoEvent)
  def self.inherited(child)
    child.instance_eval do
      def model_name
        Event.model_name
      end
    end
    super
  end

  # nb. This is used to delete DemoEvents from teams when the exit demo mode
  #      the call is in DemoService.rb
  def nuke
    self.open_graph_event.destroy unless self.open_graph_event.nil?
    self.teamsheet_entries.destroy_all
    self.messages.destroy_all
    self.activity_items.destroy_all
    self.result.destroy unless self.result.nil?
    self.destroy
  end

  def create_new_version?
    @version_lock_on == false
  end
end
