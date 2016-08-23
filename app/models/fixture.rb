class Fixture < ActiveRecord::Base
	include Trashable
	include Tenantable

	before_destroy :trash_dependents

	# for edit_mode shit TS
	@@not_tracked = %w(id division_season_id division_id created_at updated_at edited edits publish manual_override result_id points_id source_id source) #publish is metashit

	default_scope includes(:result, :location)

	belongs_to :division_season
	has_one :league, through: :division_season

	belongs_to :home_event, class_name: "Event"
	belongs_to :away_event, class_name: "Event"
	belongs_to :home_team, class_name: "Team"
	belongs_to :away_team, class_name: "Team"

	belongs_to :location
	belongs_to :result
	belongs_to :points

	attr_accessible :title, :status, :time, :time_zone, :home_team_id, :away_team_id, :location_id, :division_id
	attr_accessible :time_tbc, :source, :source_id, :tag
	attr_accessible :competition # *** This seems to only have been used intermittently, so cannot be relied upon ***

	# for edit mode ting
	attr_accessible :edited, :edits
	serialize :edits
	before_update :process_update
	before_create :process_create

	# validations
	# not events, as playoffs etc. where teams undecided.
	# allow_nil: true, due edit_mode magic
	validates :title, length: { maximum: 70 }, allow_nil: true
	validates :status, inclusion: EventStatusEnum.values, allow_nil: true
	validate :no_events_without_teams
	validate :teams_own_events
	validate :teams_in_division
	validates :time_zone, presence: true, :if => lambda { !self.time.nil? }

	# Scopes
	scope :past, ->{ where("time < ?", Time.now) }
	scope :future, ->{ where("time > ?", Time.now) }

	def self.find_by_faft_id(id)
	  return nil if id.nil?
	  self.where(source_id: id, source: "faft").first
	end

	# DEPRECATED
	# to ease the transition over to division_seasons. Do not use.
	def division
		self.division_season
	end

	def home_team?(team)
		return self.home_team_id == team.id
	end

 	# precautionary measures
  def faft_id
    self.source_id
  end
  # precautionary measures
  def faft_id=(value)
    self.source_id = value
  end

  def event_for_team(team)
  	home_team?(team) ? home_event : away_event
  end

	# validation
	def no_events_without_teams
		if home_team.nil? && !home_event.nil?
			errors.add(:home_event, "cannot have home_event without home_team")
		end
		if away_team.nil? && !away_event.nil?
			errors.add(:away_event, "cannot have away_event without away_team")
		end
	end

	# validation
	def teams_own_events
		if !home_event.nil? && home_event.team != home_team
			errors.add(:home_event, "home_event must belong to home_team")
		end
		if !away_event.nil? && away_event.team != away_team
			errors.add(:away_event, "away_event must belong to away_team")
		end
	end

	# validation
	def teams_in_division
		if !home_team.nil? && !home_team.in_division_season?(division_season)
			errors.add(:home_team, "home_team must be in the division season")
		end
		if !away_team.nil? && !away_team.in_division_season?(division_season)
			errors.add(:away_team, "away_team must be in the division season")
		end
	end


	# make the edits made to this fixture live
	def publish_edits!
		self.edits ||= {}
		self.edits["publish"] = true
		self.save!
	end

	def manual_override!
		self.edits ||= {}
		self.edits["manual_override"] = true
	end

	def clear_edits!
		self.edits = {}
		edited = false
		self.save!
	end

	def trash_dependents
		# so that we don't get problems if a new one is created
		source_id = nil

		# handled by vestral
		home_event.destroy unless home_event.nil?
		# handled by vestral
		away_event.destroy unless away_event.nil?

		result.trash! unless result.nil? || result.is_special?
		points.trash! unless points.nil?
	end

	# set all attrs to those in edits hash. (This doesn't publish them, but
	#   allows you to pretend they have been until you reload or save, or
	#   whatever.
	def show_edits!
		return unless self.edited?
		self.edits.each do |k, v|
			next if @@not_tracked.include? k
			self.send("#{k}=", v)
		end
	end

  def bftime(recalc=false)
    @bftime = BFTime.new(self.time, self.time_zone, self.time_tbc) if not @bftime || recalc
    @bftime
  end

  def time_local
  	return nil if self.time_zone.nil?
    tz = TZInfo::Timezone.get(self.time_zone)
    return tz.utc_to_local(self.time)
  end

  def time_local=(time_local)
  	return if time_local.blank?
    time_local = Time.parse(time_local) if time_local.is_a? String

    tz = TZInfo::Timezone.get(self.time_zone)
    self.time = tz.local_to_utc(time_local)
  end

  def in_league?(league)
  	return false if league.nil?
  	return true if league.is_a?(Integer) && self.league.id == league
  	return false unless league.is_a? League
  	self.league_id == league.id
  end

  def is_deletable?
  	self.home_event.nil? && self.away_event.nil?
  end

  def home_team_editable?
  	self.home_event.nil?
  end

  def away_team_editable?
  	self.away_event.nil?
  end

  alias_method :original_result, :result
  def result
  	r = self.original_result
  	return r unless r.nil?
  	Result
  	return AbandonedResult.new if self.status == EventStatusEnum::ABANDONED
  	return CancelledResult.new if self.status == EventStatusEnum::CANCELLED
  	return PostponedResult.new if self.status == EventStatusEnum::POSTPONED
  	return VoidResult.new if self.status == EventStatusEnum::VOID
  	nil
  end


	def competition?
		self.division_season.competition?
	end

	private
	def process_create
		self.edits ||= {}

		# check no events.
		if self.edits["manual_override"] != true && (!self.home_event_id.nil? || !self.away_event_id.nil?)
			raise "events must not be set manually"
		end
		raise "cannot create fixture with status deleted" if self.status == EventStatusEnum::DELETED

		# put everything in edits hash
		tracked_edits = 0
		self.changes.each do |k, v|
			next if @@not_tracked.include? k
			tracked_edits += 1
			self.edits[k] = v[1]
			self.send("#{k}=", v[0])
		end

		# set edited to true
		self.edited = tracked_edits > 0

		make_changes_live if !self.edits.nil? && self.edits["publish"] == true
	end

	def process_update
		make_changes_live and return true if !self.edits.nil? && self.edits["publish"] == true

		# check what has changed, stick it in the hash
		# put everything in edits hash
		tracked_edits = 0
		self.edits.reject!{ |k| !changes.include?(k) && !@@not_tracked.include?(k) }
		self.changes.each do |k, v|
			next if @@not_tracked.include? k
			tracked_edits += 1
			self.edits[k] = v[1]
			self.send("#{k}=", v[0])
		end

		check_consistency unless self.edits["manual_override"] == true

		self.edited = tracked_edits > 0

		true
	end

	def check_consistency
		# we don't want teams or events to change, else that will fuck shit up...
		# but if they have they'll be in the edit hash, so it'll be easy to spot
		raise "home_team cannot be changed once published" if self.edits.has_key?("home_team_id") && !self.home_event.nil?
		raise "away_team cannot be changed once published" if self.edits.has_key?("away_team_id") && !self.away_event.nil?
		raise "home_event cannot be changed once published" if self.edits.has_key?("home_event_id")
		raise "away_event cannot be changed once published" if self.edits.has_key?("away_event_id")
		raise "fixture cannot be edited once published" if self.edits["status"] == EventStatusEnum::DELETED && !self.is_deletable?
	end

	def make_changes_live
		# create events as appropriate.
		create_home_event = self.home_team_id.nil? && !edits["home_team_id"].nil?
		create_away_event = self.away_team_id.nil? && !edits["away_team_id"].nil?

		# update the events as appropriate
		update_home_event = !self.home_event_id.nil?
		update_away_event = !self.away_event_id.nil?

		# override the above if we've been manualy smashing shit
		if edits["manual_override"]
			create_home_event = (!self.home_team_id.nil? || !edits["home_team_id"].nil?) && (self.home_event_id.nil? && edits["home_event_id"].nil?)
			create_away_event = (!self.away_team_id.nil? || !edits["away_team_id"].nil?) && (self.away_event_id.nil? && edits["away_event_id"].nil?)
			update_home_event = !self.home_event_id.nil? || !edits["home_event_id"].nil?
			update_away_event = !self.away_event_id.nil? || !edits["away_event_id"].nil?
		end

		# iterate through hash and set variables.
		self.edits.each do |k, v|
			next if @@not_tracked.include? k
			self.send("#{k}=", v)
		end
		self.edits = {}

		self.home_event = create_event_from_fixture(home_team, away_team) if create_home_event
		self.away_event = create_event_from_fixture(away_team, home_team) if create_away_event
		update_event_from_fixture(self.home_event, away_team) if update_home_event
		update_event_from_fixture(self.away_event, home_team) if update_away_event

		self.edited = false

		# ensure still valid
		if !self.valid?
			self.errors.each { |e, v| logger.info ("#{e} #{v}") }
			raise "publishing edits invalidated fixture #{self.id}"
		end

		true # we need to return true so the 'and' evaluates to true
	end

	def update_event_from_fixture(event, other_team=nil)
		# handle changing of cancellation status
		if self.status != event.status
			# TODO: notify of cancellation if self.status == EventStatusEnum::CANCELLED
			# TODO: notify of uncancellation if self.status == EventStatusEnum::NORMAL
		end

		title = "vs ?"
		title = self.title unless self.title.blank?
		title = "vs #{other_team.name}" unless other_team.nil?
		title = "#{self.title}: vs #{other_team.name}" unless self.title.nil? || other_team.nil?

		event.assign_attributes({
			title: title,
			location: self.location,
			status: self.status,
			time: self.time,
			time_tbc: self.time_tbc,
			time_zone: self.time_zone,
		})

		# only save if there are changes
		if event.changes.count > 0
			event.last_edited = Time.now
			event.save!
		end
	end

	def create_event_from_fixture(team, other_team)
		title = "vs ?"
		title = self.title unless self.title.blank?
		title = "vs #{other_team.name}" unless other_team.nil?
		title = "#{self.title}: vs #{other_team.name}" unless self.title.nil? || other_team.nil?

		event = Event.new({
			title: title,
			game_type: GameTypeEnum::GAME,
			location: self.location,
			status: self.status,
			time: self.time,
			time_zone: self.time_zone,
			time_tbc: self.time_tbc,
			last_edited: Time.now,
			response_required: 0
		})
		event.tenant = LandLord.new(self).tenant # extra layer of redirection so we can mash shit
		event.user = team.organisers.first
		event.save!
		#SR - This is a horrible flag to control push notifications but can't do anything in this time-frame.
		TeamEventsService.add(team, event, send_push_notifications=false)

		event
	end

end
