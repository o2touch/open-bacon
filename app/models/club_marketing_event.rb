class ClubMarketingEvent < ActiveRecord::Base
	belongs_to :club_marketing_data

	attr_accessible :event_type, :date, :data, :email_id
	
	serialize :data
end