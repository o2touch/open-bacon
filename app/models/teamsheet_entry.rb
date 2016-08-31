class TeamsheetEntry < ActiveRecord::Base
  
  validates_uniqueness_of :user_id, :scope => :event_id
  validates_uniqueness_of :token
  
  belongs_to :event
  belongs_to :user
  
  has_many :invite_responses, :order => 'created_at DESC', :dependent => :destroy
  has_many :sms_replies, :dependent => :destroy
  has_many :reminders, :class_name => 'InviteReminder', :order => 'created_at DESC', :dependent => :destroy
 
  has_one :activity_item, :as => "obj"
 
  has_one :open_graph_play_in
  
  attr_accessible :token, :invite_sent, :event, :user, :checked_in, :checked_in_at
  
  before_validation :create_token
  
  after_create :push_create_to_feeds #SR - Should this be after_save?
  
  after_save :touch_via_cache
  before_destroy { |x| x.touch_via_cache(Time.now) }

  def touch_via_cache(time=self.updated_at)
    time = time.utc
    self.event.teamsheet_entries_last_updated_at = time unless self.event.nil?
    self.user.events_last_updated_at = time unless self.user.nil?
    return true
  end

  def push_create_to_feeds
    activity_item = ActivityItem.new
    activity_item.subj = self.user
    activity_item.obj = self
    activity_item.verb = :added_to
    activity_item.save!

    activity_item.push_to_newsfeeds unless self.event.instance_of? DemoEvent
    
    activity_item.push_to_profile_feed(self.user)
    activity_item.push_to_profile_feed(self.event.team)
    activity_item.push_to_activity_feed(self.event)
    
    activity_item 
  end  

  def self.find_by_event_and_user(event, user)
    TeamsheetEntry.where(event_id: event.id, user_id: user.id).first
  end
  
  def send_push_notification(type="add", socketID=nil)
    # Removed. This send the web socket type push, not mobile app type push.
    # TeamsheetEntry.delay_for(2.seconds, queue: 'pusher').send_push_notification(self.id, type, socketID)
  end

  def self.send_push_notification(id, type="add", socketID=nil)
    # Removed. This send the web socket type push, not mobile app type push.
    # tse = TeamsheetEntry.find(id)

    # rabl_out = Rabl::Renderer.new('api/v1/teamsheet_entries/show_reduced_activity_item', tse, :view_path => 'app/views', :format => 'hash', :scope => BFFakeContext.new).render
    # name = "event-#{tse.event.id}-teamsheet"
    # Pusher[name].trigger(
    #   type + '_teamsheet-entry',
    #   rabl_out,
    #   socketID
    # )
  end
    
  def add_open_graph(fbid)
    self.open_graph_play_in = OpenGraphPlayIn.create(:fbid => fbid) if(!fbid.nil? && self.open_graph_play_in.nil?)
  end
  

  def create_token
    self.token = SecureRandom.uuid
  end

  # ***************
  # Looking for def create_invite_response_if_changed ?
  # Checkout TeamsheetEntries.set_availability instead!
  # TS
  # *******
  
  # These two methods return availability. I want to change the terminology
  #  to talk about availablity, rather than responses, but, as yet, have 
  #  refrained from doing so because they're too deeply engrained into all
  #  parts of the project. Wait for full TSE refactor! TS
  def latest_response
    return nil if self.invite_responses.empty?
    self.invite_responses.first
  end
  
  def response_status
    return AvailabilityEnum::NOT_RESPONDED if latest_response.nil?
    latest_response.response_status
  end
  
  def latest_reminder
    self.reminders[0]
  end
 
  def as_json(options)
    super(options.merge({:methods => [:response_status, :latest_reminder], :include => {:reminders=> {}, :user => {:include => {:profile => {:methods => [:profile_picture_thumb_url]}}}}}))
  end    
end
