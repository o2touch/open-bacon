# This class represents contacts we scrape for leagues/clubs etc.
#
#  It's essentially just a subset of user, but I wanted to separate it
#  to remove all the complexity of dealing with real user objects, and
#  so that, if we add methods, we aren't adding shit to the real user 
#  model. TS
class ScrapedContact < ActiveRecord::Base

	# polymorphic relationship, so can be linked to teams/divs/clubs
	# Could make this many to many, but that seems like overkill (for now). TS
	belongs_to :org, polymorphic: true

	attr_accessible :name, :position, :phone, :email, :contact_link, :org

	# to match user.rb
	def mobile_number
		self.phone
	end
end