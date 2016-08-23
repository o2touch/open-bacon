FactoryGirl.define do
	meta_data = { mailer: 'EventMailer' }
  factory :email_notification_item do |n|
    n.tenant_id 1
  	n.medium 'email'
    n.datum 'player_event_created'
    n.processed_at nil
    n.created_at Time.now
    n.updated_at Time.now
    n.meta_data meta_data
    n.status 2
    n.attempts 0
    n.user
    n.app_event
  end
end