FactoryGirl.define do
  factory :email_notification do |n|
    n.association :sender, :factory => :user
    n.notification_item nil
  end
end