class PointsAdjustment < ActiveRecord::Base

	belongs_to :division_season
	belongs_to :team

	attr_accessible :adjustment, :adjustment_type, :desc, :division_season, :team, :source, :source_id

	validates :team, :division_season, presence: true
	validates :adjustment_type, presence: true, inclusion: PointsAdjustmentTypeEnum.values
	validates :adjustment, numericality: true
	validate :team_in_division

	def team_in_division
		return if team.nil? || self.division_season.nil? # other validations will catch

		if !DivisionSeason.find(self.division_season.id).teams.include? self.team
			errors.add(:team, "team not in division") 
		end
	end
end