class League < ActiveRecord::Base
  include LeagueSearch
  include Tenantable
  include Configurable
  include Roleable

  belongs_to :location

  has_many :fixed_divisions
  has_many :division_seasons, through: :fixed_divisions
  has_many :all_teams, through: :division_seasons, class_name: "Team"

  # has_many :league_roles created via Roleable
	has_many :organisers,
					  :source => :user,
					  :through => :league_roles,
					  :conditions => ['role_id = ?', PolyRole::ORGANISER]

	has_attached_file :logo,
    :styles => { :large => "300x300#", :medium=> "120x120#", :small => "60x60#", :thumb => "30x30#" },
    :path => 'leagues/logos/:id/:style/:filename',
    :url => "/system/:hash.:extension",
    :hash_secret => "bc496440-a3cd-0130-5d9a-3c0754364732",
    :default_url => "/assets/profile_pic/league/generic_league_:style.png"
  validates_attachment_content_type :logo, :content_type => %w(image/jpeg image/jpg image/png)

  has_attached_file :cover_image,
    :path => 'leagues/logos/:id/:style/:filename',
    :url => "/system/:hash.:extension",
    :hash_secret => "bc496440-a3cd-0130-5d9a-3c0754364732",
    :default_url => "default.png"
  validates_attachment_content_type :cover_image, :content_type => %w(image/jpeg image/jpg image/png)

	attr_accessible :title, :slug, :sport, :region, :colour1, :colour2, :logo, :cover_image, :time_zone
  attr_accessible :source, :source_id, :claimed, :tag

  # start with letter, finish letter or number, has hyphens
  validates :slug, presence: true, uniqueness: { case_sensitive: false }
  validates_format_of :slug, :with => /\A[a-zA-Z](([a-zA-Z0-9-]+)[a-zA-Z0-9])?\Z/
	validates :sport, presence: true, inclusion: { in: SportsEnum.values, message: "%{value} is not a supported sport" }
  # Allow shit data, innit
  #validates :time_zone, presence: true

  serialize :settings, Hash

  before_validation :set_default_slug

  # Enable Configurable settings
  configurable settings_hash: :configurable_settings_hash, parent: :configurable_parent

  # Setup roles
  roleable roles: [PolyRole::ORGANISER]


  def self.find_by_faft_id(id)
    return nil if id.nil?
    self.where(source_id: id, source: "faft").first
  end
  # precautionary measures
  def faft_id
    self.source_id
  end
  # precautionary measures
  def faft_id=(value)
    self.source_id = value
  end

  # So that we can use the slug in URLs
  def to_param
    self.slug
  end

  # Refactor this to use configurable. TS
  def league_config
    if self.settings[LeagueConfigKeyEnum::KEY].nil?
      self.settings[LeagueConfigKeyEnum::KEY] = {}
      self.save
    end

    DEFAULT_LEAGUE_CONFIG.merge(self.settings[LeagueConfigKeyEnum::KEY])
  end


  # convenience methods for fixed/division/season shit
  # TODO: CACHING TS
  # return the current division_seasons (ie. this season's divisions)
  def divisions
    self.fixed_divisions.map(&:current_division_season)
  end

  # TODO: CACHING TS
  # return the teams in the current division_seasons
  def teams
    self.divisions.map(&:teams).flatten.uniq
  end

  # TODO: CACHING TS
  # return the fixtures in the current division_seasons
  def fixtures
    self.divisions.map(&:fixtures).flatten
  end


  def logo_thumb_url
    self.logo.url(:thumb)
  end

  def logo_medium_url
    self.logo.url(:medium)
  end

  def logo_small_url
    self.logo.url(:small)
  end

  def logo_large_url
    self.logo.url(:large)
  end

  def cover_image_url
    self.cover_image.url if self.cover_image
  end

  # this shit should be in a roles service. TS
  def has_organiser?(user)
    return false if user.nil? || !user.is_a?(User)
    self.organisers.include? user
  end
  def add_organiser(user)
    if !self.has_organiser? user
      self.league_roles.create({ role_id: PolyRole::ORGANISER, user: user})
    end
  end

  def locations
    fixtures.map{ |f| f.location }.uniq.compact
  end

  private
  def set_default_slug
    if self.slug.blank? && !self.title.blank?
      base_slug = self.title.downcase.gsub('&','and').gsub('/','').strip.gsub(' ', '-').gsub('--','-').gsub(/[^\w-]/, '').gsub('--','-')
      # remove leading part of slug, if numeric slug
      base_slug = base_slug.split("-")[1..-1].join("-") if base_slug[0] =~ /\d/

      slug = base_slug
      n = 1
      while League.where(slug: slug).count > 0
         slug = base_slug + n.to_s
         n += 1
      end

      self.slug = slug
      # would be nice not to have to save if could guarantee model was about to be saved anyway
      #self.save
    end
  rescue Exception => e
    puts e.to_yaml
  end
end