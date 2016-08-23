class CreateEmailCampaignSents < ActiveRecord::Migration
  def change
    create_table :email_campaign_sents do |t|
      t.string :email_campaign_id
      t.string :email
      t.string :template_id
      t.string :data
      t.timestamps
    end
  end
end
