class ActiveCampaignEvent < ActiveRecord::Base
	attr_accessible :id, :email, :user_id, :event, :list_id, :campaign_id, :meta_data, :ip, :event_time
end