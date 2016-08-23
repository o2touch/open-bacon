class ClaimProfileCampaignEmail < ActiveRecord::Base
  attr_accessible :profile_id, :email_id, :campaign_id, :email_type
  
  has_one :unclaimed_team_profile
  
  def markAsFollowedUp
    self.follow_up = "Y"
    self.save
  end
  
end
