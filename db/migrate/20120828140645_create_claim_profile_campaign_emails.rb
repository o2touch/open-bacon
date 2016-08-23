class CreateClaimProfileCampaignEmails < ActiveRecord::Migration
  def change
    create_table :claim_profile_campaign_emails do |t|
      
      t.string :profile_id
      t.string :email_id
      t.string :campaign_id
      
      t.timestamps
    end
  end
end
