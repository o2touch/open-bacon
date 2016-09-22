class User < ActiveRecord::Base    
  include RedisModule
  include VanityUsernames
  include CacheHelper
  include Messageable
  include Tenantable
  include Configurable

  #Note before_validation block!
  validate :contact_information_is_valid?, :username_is_valid?
  validates :email, :allow_blank => true, :uniqueness => { :case_sensitive => false }, :length => { :minimum => 5 }, :format => { :with => /[^@]*[^@.]+@[^@.]+\.[^@.]+[^@]*/ } 
  validates :username, :allow_blank => true, :uniqueness => { :case_sensitive => false } 
  validates_presence_of :name
  validates_presence_of :time_zone

  before_create :create_profile_if_not_exist
  before_create :internationalize_mobile_number

  has_and_belongs_to_many :roles, :join_table => :roles_users
  
  belongs_to :profile, :class_name => "UserProfile"
  
  has_many :teamsheet_entries
  has_many :events_playing, :source => :event, :through => :teamsheet_entries
  has_many :invite_responses
  
  has_many :invite_reminders, :class_name => "InviteReminder", :through => :teamsheet_entries, :source => :reminders
  has_many :events_created, :class_name => "Event"
  has_many :sms_sents
  has_many :authorizations, :dependent => :destroy

  has_many :mobile_devices
  
  has_many :team_invites_sent, :class_name => "TeamInvite", :source => :sent_by
  has_many :team_invites_received, :class_name => "TeamInvite", :source => :sent_to
  
  has_many :activity_item_comments
  has_many :activity_item_likes
  has_many :activity_item_links, :as => :feed_owner
  has_many  :profile_feed_activity_items, 
            :source => :activity_item, 
            :through => :activity_item_links, 
            :conditions => ['feed_type = ?', :profile]
  
  has_many :activity_items, :as => :subj

  # all roles, on all things
  has_many :poly_roles

  has_many  :tenant_roles, class_name: 'PolyRole', conditions: "obj_type = 'Tenant'"
  has_many  :tenants_as_organiser,
            source: :obj,
            source_type: 'Tenant',
            through: :league_roles, 
            conditions: ['role_id = ?', PolyRole::ORGANISER]

  has_many  :league_roles, class_name: 'PolyRole', conditions: "obj_type = 'League'"
  has_many  :leagues_as_organiser,
            source: :obj,
            source_type: 'League',
            through: :league_roles, 
            conditions: ['role_id = ?', PolyRole::ORGANISER]
  
  has_many  :team_roles, class_name: 'PolyRole', conditions: "obj_type = 'Team'"
  has_many  :teams_as_player, 
            source: :obj,
            source_type: 'Team',
            :through => :team_roles, 
            :conditions => ['role_id = ?', PolyRole::PLAYER]
  has_many  :teams_as_organiser, 
            source: :obj,
            source_type: 'Team',
            :through => :team_roles, 
            :conditions => ['role_id = ?', PolyRole::ORGANISER]
  has_many  :teams_as_parent,
            source: :obj,
            source_type: 'Team',
            :through => :team_roles,
            :conditions => ['role_id = ?', PolyRole::PARENT]
  has_many  :teams_as_follower,
            source: :obj,
            source_type: 'Team',
            :through => :team_roles,
            :conditions => ['role_id = ?', PolyRole::FOLLOWER]

  has_many  :parent_child_relations,
            :class_name    => ParentChild.name,
            :foreign_key   => ParentChild::PARENT_KEY,
            :conditions    => ParentChild::CONDITIONS,
            :dependent     => :destroy

  has_many  :children,
            :class_name    => User.name,
            :through       => :parent_child_relations,
            :source        => ParentChild::CHILD_FIELD,
            :source_type   => User.name
  
  # auto_event_reminders
  #   0: send automatically
  #   1: ask me via email first, send on confirm
  store :settings, accessors: [:auto_event_reminders, :generated_password, :stated_faft_team_role]
  
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :invitable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :token_authenticatable,
         :omniauthable, :async
  

  attr_accessible :name, :email, :password, :password_confirmation, :remember_me, :lazy_id, :role_ids, :username, :time_zone, :mobile_number, :country, :created_at, :team_roles 
  attr_accessible :invited_by_source_user_id, :invited_by_source, :settings, :updated_at, :id, :dob, :incoming_email_token, :stated_faft_team_role, :tenanted_attrs

  serialize :tenanted_attrs
  
  after_save :touch_via_cache
  before_validation :downcase_username
  before_create :generate_email_token
  before_destroy { |x| x.touch_via_cache(Time.now) }

  # SCOPES
  scope :mitoo, -> { where("invited_by_source = \"MITOO\"") }

  # Enable Configurable Settings
  configurable settings_hash: :configurable_settings_hash, parent: :configurable_parent


  # Old, should check if still appropriate. TS
  before_validation do
    begin 
      self.mobile_number = BluefieldPhoneNumberFormatter.new(self.mobile_number, self.country).format
    rescue Exception => e
    end
    true # Must return true
  end

  # if email changed, set unsubscribe to false
  before_save do
    self.unsubscribe = false if self.changed.include? "email"
    true
  end

  # for callback
  def internationalize_mobile_number
    return if self.mobile_number.blank?

    begin
      default = "gb"
      default = self.country.downcase
      GlobalPhone.default_territory_name = default

      number = GlobalPhone.parse(self.mobile_number)
      self.mobile_number = number.international_string if number.valid?
    rescue
      # oh well, we did our best
    end
  end

  # for callback
  def downcase_username
    self.username.downcase! unless self.username.nil?
  end

  def generate_email_token
    self.incoming_email_token = SecureRandom.hex
  end

  def touch_via_cache(time=Time.now)
    time = self.updated_at unless self.updated_at.nil?
    time = time.utc
    self.team_roles.each do |role|
      role.obj.team_roles_last_updated_at = time unless role.obj.nil?
    end
    return true
  end

  def first_name
    return nil if self.name.nil?

    names = self.name.gsub(/\s+/m, ' ').strip.split(" ")
    names.empty? ? self.name : names[0]
  end

  def last_name
    return nil if self.name.nil?

    names = self.name.gsub(/\s+/m, ' ').strip.split(" ")

    return "" if names.size == 1

    names.delete_at(0)
    names.empty? ? self.name : names.join(" ")
  end

  # Create an invited user
  # TODO: Add checks here
  def self.create_invited(params)
    u = User.create!(params)
    u.add_role(RoleEnum::INVITED)
    u
  end

  # these two methods tell devise not to log in a user, and why, even if they
  # authenticate correctly. TS
  # For further security I have overiden devises sign_in method to make the 
  # same check as below. See config/initializers/devise_patch.rb TS
  def active_for_authentication?
    super && !self.role?(RoleEnum::NO_LOGIN)
  end

  def inactive_message #Is this being used?
    !self.role?(RoleEnum::NO_LOGIN) ? super : :user_has_no_login_role
  end


  def rabl_cache_key
    key_extension = self.updated_at ? "#{self.events_last_updated_at.utc.to_s(:number)}/#{self.teamsheet_entries_last_updated_at.utc.to_s(:number)}/#{self.team_roles_last_updated_at.utc.to_s(:number)}" : "none"
    profile_cache_key = self.profile ? "#{self.profile.cache_key}" : "none"
    "#{self.cache_key}/#{profile_cache_key}/#{key_extension}"
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
    cache_key = "#{self.cache_key}/#{self.teamsheet_entries_last_updated_at.utc.to_s(:number)}/TeamsheetEntry"
    fetch_from_cache cache_key do
      self.teamsheet_entries.find(:all, :include => :reminders)
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
  
  def cached_team_roles(team=nil)
    Role
    PolyRole
    cache_key = "#{self.cache_key}/#{self.team_roles_last_updated_at.utc.to_s(:number)}/TeamRole"

    if team.nil?
      begin
        fetch_from_cache cache_key do
          self.team_roles(true)
        end
      rescue 
        return self.team_roles(true) #Temporay fix for a bug we cannot uncover.
      end
    else
      fetch_from_cache "#{cache_key}:team:#{team.id}" do
        self.team_roles.where(:obj_id => team.id)
      end
    end
  end

  def tenant_roles_cache_key
    "#{self.cache_key}/tenant_roles_last_updated_at"
  end

  def tenant_roles_last_updated_at
    fetch_from_cache self.tenant_roles_cache_key do
      self.updated_at ? self.updated_at : Time.now
    end
  end

  def tenant_roles_last_updated_at=(value)
    Rails.cache.write self.tenant_roles_cache_key, value
  end

  def cached_tenant_roles
    Role
    PolyRole
    cache_key = "#{self.cache_key}/#{self.tenant_roles_last_updated_at.utc.to_s(:number)}/TeamRole"

    begin
      fetch_from_cache cache_key do
        self.tenant_roles(true)
      end
    rescue 
      return self.tenant_roles(true) #Temporay fix for a bug we cannot uncover.
    end
  end

  def cached_roles
    Role
    
    cache_key = "#{self.cache_key}/Role"

    fetch_from_cache cache_key do
      self.roles(true)
    end
  end

  def username_is_valid?    
    return if self.username.nil?
    self.errors[:username] << "Username is invalid" unless self.username.match(/\A[A-Za-z][A-Za-z0-9-]+\Z/)
    self.errors[:username] << "Reserved username" if not VanityUsernames.username_is_valid_route?(self.username)
  end
  
  def set_default_username
    if self.username.blank? && self.role?(RoleEnum::REGISTERED)
      encoding_options = {
        :invalid           => :replace,
        :undef             => :replace,
        :replace           => ''
      }
      base_username = self.name.downcase.encode Encoding.find('ASCII'), encoding_options
      base_username.gsub!(" ","-")
      username = base_username
      n = 1
      while !User.find_by_username(username).nil?
         username = base_username + n.to_s()
         n += 1
      end
      self.username = username
      # would be nice not to have to save if could guarantee model was about to be saved anyway
      self.save
    end
  end
   
  def self.create_if_not_exists(data) #Is this being used?
    if data.has_key?("id")
      user = User.find(data["id"])
    else 
      if data['email'] != ""
        user = User.find_by_email(data['email'])
      elsif data['mobile_number'] != ""
        user = User.find_by_mobile_number(data['mobile_number'])
      end

      if user.nil?
        user = User.new(
          :name => data['name'],
          :email => data['email'],
          :mobile_number => data['mobile_number'],
          :country => data['country'],
          :time_zone => data['time_zone'],
          :password => "aaaaaa",
          :invited_by_source_user_id => data['invited_by_source_user_id'],
          :invited_by_source => data['invited_by_source']
        )
        user.add_role("Invited")
        user.save!          
      end
    end
    user    
  end
  
  def create_profile_if_not_exist #Is this being used?
    if self.profile.nil?
      self.profile = UserProfile.create(
        :bio => nil
      )
    end
    self.profile
  end

  def generate_password
    tmp_password = /[:word:]{6}-[:word:]{6}-\d{2}/.gen.downcase
    self.password = tmp_password
    self.generated_password = tmp_password
    self.save
  end

  def clear_generated_password
    self.generated_password = nil
    self.save
  end

  # This method is specific to parents... Should we put this and other like it
  # into a module we can mixin at runtime if the user has kids??
  def child_invited_to?(event)
    #SLOW SLOW SLOW
    #self.child_ids.each ....
    return false if children.count == 0

    children.each do |child|
      return true if event.is_invited? child
    end
    false
  end
  
  def previous_event
    self.past_events(true).first
  end
  
  def past_events(sorted = false)
    events = self.events.find_all { |e| (!e.time.nil? && e.time < Time.now) }
    if sorted
      events.sort_by(&:time)
    end
    events
  end
  
  def next_event 
    self.future_events(true).last
  end
  
  def future_events(sorted = false)
    events = self.events.find_all { |e| (!e.time.nil? && e.time >= Time.now) }
    if sorted
      events.sort_by(&:time)
    end
    events
  end

  def teams
    self.cached_team_roles.map(&:obj).compact.uniq
  end

  # TODO: cache me!
  def leagues_as_player
    leagues = self.teams_as_player.map{ |t| t.leagues }
    leagues.flatten.compact.uniq
  end

  # TODO: cache me!
  def leagues_as_team_organiser
    leagues = self.teams_as_organiser.map{ |t| t.leagues }
    leagues.flatten.compact.uniq
  end

  # TODO: prob change this to player league_roles, if we can guarentee it
  def leagues_through_teams
    self.cached_team_roles.map{ |tr| tr.obj.leagues unless tr.obj.nil? }.flatten.compact.uniq
  end

  def faft_teams_as_organiser
    self.teams_as_organiser.select { |x| x.faft_team? }
  end
  
  def events_last_updated_at
    fetch_from_cache "#{self.cache_key}/events_last_updated_at" do
      self.updated_at
    end
  end

  def events_last_updated_at=(value)
    Rails.cache.write "#{self.cache_key}/events_last_updated_at", value
  end
  
  def cached_events
    TeamProfile
    Team
    Event

    cache_key = "#{self.cache_key}/#{self.teams_as_follower.map(&:id).join(',')}/#{self.events_last_updated_at.utc.to_s(:number)}/Event"

    events = [] 
    fetch_from_cache cache_key do
      follower_events = teams_as_follower.map(&:cached_events).flatten
      self.events_playing(true) | self.events_created(true) | follower_events
    end  
  end

  def events
    self.cached_events
  end
  
  def unique_game_invites    #Is this being used?
    oInvites = []
    # self.events.each do |event|
    #   event.teamsheet_entries.each do |tse|
    #     unless oInvites.include?(tse.user_id)
    #       oInvites << tse.user_id
    #     end
    #   end
    # end
    oInvites.size
  end
  
  def default_settings(name) 
    defaults = {
      :auto_event_reminders => 0,
      :completed_event_page => false
    }
    return defaults[name]
  end
  
  def get_setting(name)
    if !self.settings[name].nil?
      return self.settings[name]
    else
      return self.default_settings(name)
    end
  end

  def update_setting(name, value)
    self.settings[name] = value
  end 
  
  # currently delegate to teammates, but make this better later once we have
  # more of a concept of "friends"
  def friends
    self.teammates
  end
  
  # this method sucks and should be much better
  def teammates
    
    # Calculate cache key
    teams_cache_key = ""
    self.teams.each do |team|
      teams_cache_key += "#{team.id}-#{team.team_roles_last_updated_at.utc.to_s(:number)}"
    end

    teammates_cache_key = "#{self.cache_key}/#{teams_cache_key}/Teammates"
 
    # UserProfile
    fetch_from_cache teammates_cache_key do
      arTeammatesIds = []
      self.teams.each do |team|
        team.cached_team_roles.each do |tr|
          unless tr.nil? || tr.user_id == self.id || arTeammatesIds.include?(tr.user_id)
          arTeammatesIds << tr.user_id
          # count = count + 1
          # break if count == 10
          end
        end
      end

      User.includes(:profile).find(arTeammatesIds)
    end
  end
  
  def contact_information_is_valid?
    self.errors[:base] << "Must provide at least one form of contact information." unless self.mobile_number or self.email
  end

  def junior?
    false
  end

  def parent?
    #Call size on children to access cached count
    (not junior?) and self.children.size > 0
  end

  def role?(role_name)
    camalized_role_name = role_name.to_s.camelize
    fetch_from_cache "#{self.cache_key}#{camalized_role_name}" do
      self.roles.find_by_name(camalized_role_name) ? true : false;
    end
  end

  def has_role?(role_name) 
  #SR - I want to use this in favor of role? to allow us to be more expressive in code and in specs.
  #e.g. x.should have_role RoleEnum::INVITED
    role?(role_name)
  end

  def get_role_from_name(role_name)
    Role.cache_find_by_name(role_name)
  end
  
  def add_role(role_name)
    camalized_role_name = role_name.to_s.camelize
    self.roles << self.get_role_from_name(role_name) unless self.role?(role_name)
    self.save! #Trigger updated_at to update
    Rails.cache.write "#{self.cache_key}#{camalized_role_name}", true
    #self.set_default_username
    return self 
  end

  def delete_role(role_name)
    camalized_role_name = role_name.to_s.camelize
    self.roles.delete(self.get_role_from_name(camalized_role_name)) if self.role?(camalized_role_name)
    self.save! #Trigger updated_at to update
    Rails.cache.write "#{self.cache_key}#{camalized_role_name}", false
    return self
  end
  
  def is_registered?
    self.role?(RoleEnum::REGISTERED)
  end

  # Introduced this is reduce fragility when checking whether user has activated
  # However, ideally this needs to be refactored to use is_registered? - PR
  # Used to determine whether a user needs to activate their account
  def has_activated_account?
    (self.encrypted_password != "" || self.authorizations.count > 0)
  end

  def is_organiser? #Is this being used?
    (self.events_created.count > 0 || self.teams_as_organiser.count > 0)
  end

  def needs_password?
    (self.encrypted_password.blank? && self.is_registered?)
  end
  
  def was_invited
    !self.invited_by_source_user_id.nil?
  end
  
  def users_invited
    user_ids = $redis.smembers(self.redis_key(:invited))
    User.where(:id => user_ids)
  end
  
  def log_invited(user) #Is this being used?
    #$redis.sadd(self.redis_key(:invited), user.id)
  end
  
  def as_json(options={}) #Is this being used?
    options = options.merge(:methods => [:mobile_number], 
                            :include => {:roles => {},
                                          :profile => {:methods=> [:profile_picture_thumb_url,:profile_picture_medium_url,:profile_picture_small_url,:profile_picture_large_url]},
                                          :teams_as_organiser => {},
                                          :team_roles => {}
                                          })
    super(options)
  end
  
  def updatable_users #Is this being used?
    updatable_users = [self]

    self.teams_as_organiser.each do |team|
      team.players.each do |player|
        unless updatable_users.include?(player)
           updatable_users << player
        end
      end       
    end
    updatable_users
  end
  
  def fb_connected?
    self.authorizations.size > 0
  end

  def pushable_mobile_devices(tenant=nil)
    tenant ||= LandLord.default_tenant
    app_id = -1
    app_id = tenant.mobile_app.id unless tenant.mobile_app.nil?

    # TODO: do something with the supplied tenant TS
    self.mobile_devices.select(&:pushable?).select{ |md| md.mobile_app_id == app_id }
  end

# refactor this shit out
  def should_send_push_notifications?
    self.pushable_mobile_devices.size > 0
  end

  def should_send_email?
    return false if self.email.nil?
    return false if self.unsubscribe
    true
  end

  def should_send_sms?
    self.mobile_number.nil? ? false : true
  end

  def should_never_notify?
    false
  end
# up to here... TS

  # This is horrible, non-scaleable and should not be here. But it's used. - PR
  # TODO: Refactor this into an tenant related model/module
  def needs_o2_fields?
    self.is_o2_touch_user? && (self.tenanted_attrs.nil? || !self.tenanted_attrs.has_key?(:player_history))
  end
  
  def to_param 
    !self.username.nil? ? self.username.downcase : self.id
  end
 
  # helper method to generate redis keys
  def redis_key(str)
    "user:#{self.id}:#{str}"
  end

  # Nuking is reserved for admins only and should only be used on temporary/testing accounts
  def nuke
  
    # Event related
    self.messages.destroy_all
    self.teamsheet_entries.destroy_all
    self.events_created.each do |e|
      e.nuke
    end
    self.sms_sents.destroy

    # Invites
    BluefieldsInvite.where("sent_by_id = ?", self.id).destroy_all
    
    # Team related
    Team.where("created_by_id = ?", self.id).destroy_all
    TeamInvite.where("sent_by_id = ?", self.id).destroy_all
    TeamInvite.where("sent_to_id = ?", self.id).destroy_all
    self.team_roles.destroy_all

    #Activity Items
    self.activity_item_comments.destroy_all
    self.activity_item_likes.destroy_all
    self.activity_item_links.destroy_all

    self.profile.destroy
    self.authorizations.destroy_all
    self.roles.destroy_all
    self.destroy
  end

  # to ensure rails routing magic works for subclasses (ie. DemoUser)
  def self.inherited(child)
    child.instance_eval do
      def model_name
        User.model_name
      end
    end
    super
  end

  def self.find_by_username(username)
    u = self.find(:first, :conditions => [ "lower(username) = ?", username.downcase ])
  end

  def self.find_by_username!(username)
    u = self.find_by_username(username)
    raise ActiveRecord::RecordNotFound if u.nil?
    u
  end

  def goals
    unless @goals
      @goals = GoalChecklist.new
      @goals.add_item(OrganiserCompletedEventPage.new(self))
    end
    @goals
  end

  def unsubscribe
    UsersUnsubscribed.where({
      user_id: self.id,
      email: self.email,
    }).first_or_create
  end

  def locale
    return "en-US" if self.country == "US"
    return "en-GB" if self.country == "GB"
    return nil
  end
end
