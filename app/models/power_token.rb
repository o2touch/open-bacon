class PowerToken < ActiveRecord::Base
	validates :token, :route, presence: true
	validates :token, uniqueness: true

	belongs_to :user

	attr_accessible :route, :disabled, :expires_at, :user

	before_validation :generate_token

	def self.generate_token(path_or_object, user=nil)
		path = path_or_object if path_or_object.is_a? String
		path = path_for(path_or_object) if path.nil?

		pt = self.find_by_user_and_route(path, user)
		pt = PowerToken.create!(user: user, route: path) if pt.nil?

		pt
	end

	def self.find_by_user_and_route(route, user=nil)
		PowerToken.where(user_id: user.id).where(route: route).where(disabled: false).where("expires_at is NULL OR expires_at > ?", Time.now).first
	end

	def self.find_active_token(token)
		PowerToken.where(token: token).where(disabled: false).where("expires_at is NULL OR expires_at > ?", Time.now).first
	end

	def generate_token
		self.token = SecureRandom.uuid
	end

	# for the url helpers
	def to_param
		self.token
	end

	def redirect_path
		matches = self.route.scan(/(#.+)/)

		if matches.empty?
			"#{self.route}?token=#{self.token}"
		else
			hash = matches.first.last
			route = self.route.gsub(hash, '')
			"#{route}?token=#{self.token}#{hash}"
		end		
	end

	def token_matches?(t)
		t == self.token
	end
end