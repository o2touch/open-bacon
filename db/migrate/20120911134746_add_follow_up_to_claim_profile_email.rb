class AddFollowUpToClaimProfileEmail < ActiveRecord::Migration
  def change
    add_column :claim_profile_campaign_emails, :follow_up, :string, :default => "N"
  end
end
