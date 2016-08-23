# This class represents a league's division, throughout time.
#  This is in contrast to a DivisionSeason, that represents that division only
#  for a specific season. This owns all of the DivisionSeasons for a particular
#  division.

# It is intended that this model is used only when explicitly required, ie when
#  transitioning to a new season, or wanting to see last season's results. For
#  all other occasions, the current division season will be easily accessible
#  from the league and team models. TS
class FixedDivision < ActiveRecord::Base
	belongs_to :league

	# List of all division seasons this fixed_division has ever had
	has_many :division_seasons
	# A fixed division should only ever have a singleactive division season at one time.
	#  Others can be accepting registrations etc. but never active.
	belongs_to :current_division_season, class_name: "DivisionSeason"

	attr_accessible :league_id, :current_division_season_id, :rank, :source, :source_id, :tenant_id, :tag

end