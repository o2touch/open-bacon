class Points < ActiveRecord::Base
	include Trashable
	
	has_one :fixture

	attr_accessible :home_points, :away_points, :strategy
	serialize :home_points
	serialize :away_points

	validates :strategy, presence: true, inclusion: PointsStrategyEnum.values
	validate :points_are_numbers
	validate :points_valid_for_division


	# validation
	def points_are_numbers
		self.home_points ||= {}
		away_points ||= {}

		self.home_points.each do |k, v|
			errors.add(:home_points, "must be numeric") unless v.is_a? Numeric
		end
		self.away_points.each do |k, v|
			errors.add(:away_points, "must be numeric") unless v.is_a? Numeric
		end
	end

	def points_valid_for_division
		return if self.fixture.nil? || self.fixture.division.nil? || self.fixture.division.points_categories.nil?
		div = self.fixture.division

		home_points.each do |k, _|
			if !div.points_categories.keys.include? k.to_sym
				errors.add(:home_points, "#{k} invalid points type for division") 
			end
		end
		away_points.each do |k, _|
			if !div.points_categories.keys.include? k.to_sym
				errors.add(:away_points, "#{k} invalid points type for division") 
			end
		end
	end

	def total_home_points
		self.home_points ||= {}
		total = 0
		self.home_points.each { |_, p| total += p }
		total
	end

	def total_away_points
		self.away_points ||= {}
		total = 0
		self.away_points.each { |_, p| total += p }
		total
	end
end