class Club < ActiveRecord::Base
	include Tenantable
	include Configurable
	
	has_many :teams
	belongs_to :profile, class_name: 'TeamProfile', foreign_key: :team_profile_id
	belongs_to :location
	belongs_to :marketing, class_name: 'ClubMarketingData', foreign_key: :club_marketing_data_id

	attr_accessible :name, :profile_attributes, :location_attributes, :slug
	attr_accessible :faft_id, :contact_data

	accepts_nested_attributes_for :profile, :location

	validates :name, presence: true
  validates_format_of :slug, :with => /\A[a-zA-Z](([a-zA-Z0-9-]+)[a-zA-Z0-9])?\Z/

  before_validation(on: :create) do
  	self.generate_slug
  end

  configurable settings_hash: :configurable_settings_hash, parent: :configurable_parent

  def to_param
    self.slug
  end

  # stolen from faft division. TS
	def generate_slug
		self.slug = self.name.downcase.gsub('&','and').gsub('/','').strip.gsub(' ', '-').gsub('--','-').gsub(/[^\w-]/, '').gsub('--','-')
	end

	def fixtures
		fetch_fixtures(:future_events)
	end

	def results
		fetch_fixtures(:past_events)
	end

	private
	def fetch_fixtures(method=:events)
		#team_fixtures = {}
		fx = []
		teams.each do |t|
			#fx = []
			t.send(method).each do |e|
				fx << e.fixture unless e.fixture.nil?
			end
			#team_fixtures[t.id] = fx.clone
		end

		#team_fixtures
		fx
	end
end