# This represents the relationship between a team and a division_season.
#  Required as teams now need aproval for certain divisions, innit.
class TeamDivisionSeasonRole < ActiveRecord::Base
	belongs_to :team
	belongs_to :division_season

	attr_accessible :team, :team_id, :division_season_id, :role, :source, :source_id

	validates :team, presence: true
	validates :division_season, presence: true
	validates :role, presence: true
end