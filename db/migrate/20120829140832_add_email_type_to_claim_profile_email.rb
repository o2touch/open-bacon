class AddEmailTypeToClaimProfileEmail < ActiveRecord::Migration
  def change
    add_column :claim_profile_campaign_emails, :email_type, :string
  end
end
