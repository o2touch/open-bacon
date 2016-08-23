class DivisionSeason < ActiveRecord::Base
  include RedisModule
  include Messageable
  include Tenantable
  include Configurable

  belongs_to :fixed_division
  has_one :league, through: :fixed_division

  has_many :team_division_season_roles
  # teams will only return the approved teams, this also returns pendings/rejected/deleted...
  has_many :all_teams, through: :team_division_season_roles, source: :team

  has_many :teams, through: :team_division_season_roles, source: :team, conditions: { team_division_season_roles: { role: TeamDSRoleEnum::MEMBER }}
  has_many :pending_teams, through: :team_division_season_roles, source: :team, conditions: { team_division_season_roles: { role: TeamDSRoleEnum::PENDING }}
  has_many :rejected_teams, through: :team_division_season_roles, source: :team, conditions: { team_division_season_roles: { role: TeamDSRoleEnum::REJECTED }}

  has_many :fixtures
  has_many :points_adjustments

  # attrs
	attr_accessible :title, :rank, :start_date, :end_date, :age_group, :points_categories, :competition
  attr_accessible :scoring_system, :track_results, :show_standings, :season_name, :source, :source_id, :current_season
	# for edit mode
	attr_accessible :edit_mode, :launched, :launched_at, :fixed_division_id, :slug, :tenant_id, :tag

  serialize :points_categories

	# validations (not many now, due to shit faft (etc.) data)
	validates :title, presence: true
	validates :age_group, presence: true, inclusion: { in: AgeGroupEnum.values, :message => "invalid age group" }
  validates :scoring_system, inclusion: ScoringSystemEnum.values, allow_nil: true
  validate :start_date_before_end_date
  validates :fixed_division, presence: true

  # callbacks
  before_create :default_points_categories
  before_validation :set_default_slug

  # Enable Configurable Settings
  configurable settings_hash: :configurable_settings_hash, parent: :configurable_parent

  # validation
  def start_date_before_end_date
    # to stop null pointer exceptions. will be caught by presence validation above
    return if self.start_date.nil? || self.end_date.nil?

    if self.start_date > self.end_date
      errors.add(:start_date, "start date must be before end date")
    end
  end

  # Old shit. To be removed. TS
  def self.find_by_faft_id(id)
    return nil if id.nil?
    self.where(source_id: id, source: "faft").first
  end
  def self.find_by_mitoo_id(id)
    return nil if id.nil?
    self.where(source_id: id, source: "mitoo").first
  end
  # precautionary measures
  def faft_id
    self.source_id
  end
  # precautionary measures
  def faft_id=(value)
    self.source_id = value
  end

  # do we use this? TS
  def graceful_league
    return league unless league.nil?
    NullLeague.new
  end


  # Get fixture methods
  def past_fixtures(prior_to=Time.now)
    fixtures.find_all { |e| (!e.time.nil? && e.time <= prior_to) }.sort_by(&:time)
  end

  def future_fixtures(from=Time.now)
    fixtures.find_all { |e| (!e.time.nil? && e.time > from) }.sort_by(&:time)
  end


  # Default of how points categories should be structured.
  # Default shouldn't be being set here. TS
  def default_points_categories
    return unless self.points_categories.nil? || self.points_categories.empty?

    self.points_categories = {
      points: "Points",
      bonus_points: "Bonus Points"
    }
  end


  # Methods todo with publishing divisions.
  # Should really remove the AppEvent shit from here. Put in controller. TS

  # when we do not want to show new fixtures which have yet to be published
  def fixtures_to_display
    self.fixtures.reject { |f| f.time.nil? }
  end

  # class method so we can delay it nice and easy like TS
  def self.publish_edits!(id, user_id)
  	division = DivisionSeason.find(id)

  	division.fixtures.each do |f|
  		f.publish_edits!
  	end

  	division.update_attributes!({edit_mode: 0})

  	#EmailNotificationService.notify_division_schedule_published(division)
    AppEventService.create(division, User.find_by_id(user_id), "published")
  end

  # launch a division - class method so can be delayed easily!
  def self.launch!(id, user_id)
    div = DivisionSeason.find(id)

    return false if div.launched?

    # publish fixtures
    div.fixtures.each do |f|
      f.publish_edits!
    end
    div.update_attributes!({edit_mode: 0})

    # this is here, as we div must be published before we email about it...
    AppEventService.create(div, User.find_by_id(user_id), "launched")

    div.update_attributes!({ launched: true, launched_at: Time.now })
    true
  end


  # generate the slug. Call back method.
  def set_default_slug
    if self.slug.blank? && !self.title.blank?
      base_slug = self.title.downcase.gsub('&','and').gsub('/','').strip.gsub(' ', '-').gsub('--','-').gsub(/[^\w-]/, '').gsub('--','-')
      slug = base_slug
      n = 1
      while !DivisionSeason.where(slug: slug, league_id: self.league_id)
         slug = base_slug + n.to_s
         n += 1
      end
      self.slug = slug
    end
  end
end