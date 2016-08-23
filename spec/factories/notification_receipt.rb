FactoryGirl.define do
  factory :notification_receipt do |n|
    n.association :recipient, :factory => :user
    n.association :notification, :factory => :email_notification
  end
end