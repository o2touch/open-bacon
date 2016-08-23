class ClubMarketingData < ActiveRecord::Base
	has_many :club_marketing_events

	attr_accessible :strategy, :split, :started_at, :finished_at, :reply_at
	attr_accessible :contact_name, :contact_position, :contact_phone, :contact_email
	attr_accessible :twitter, :junior

	serialize :team_contacts
	serialize :extra

	def contact_forename
    return nil if self.contact_name.nil?

    names = self.contact_name.gsub(/\s+/m, ' ').strip.split(" ")
    names.empty? ? self.contact_name : names.first
  end

  def contact_surname
    return nil if self.contact_name.nil?

    names = self.contact_name.gsub(/\s+/m, ' ').strip.split(" ")
    names.empty? ? self.contact_name : names.last
  end
end