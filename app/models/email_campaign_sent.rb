class EmailCampaignSent < ActiveRecord::Base
  attr_accessible :email_campaign_id, :email, :template_id, :data

  belongs_to :email_campaign
end
