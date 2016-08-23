class CreateEmailCampaigns < ActiveRecord::Migration
  def change
    create_table :email_campaigns do |t|
      t.string :campaign_id
      t.string :campaign_type
      t.string :subject_a
      t.string :template_a
      t.string :subject_b
      t.string :template_b
      t.string :layout_template
      t.string :from
      t.string :recipient_strategy_class_type
      t.timestamps
    end
  end
end
