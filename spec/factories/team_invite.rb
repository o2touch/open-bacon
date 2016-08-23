FactoryGirl.define do
  factory :team_invite do |n|
    n.sent_by factory: :user
    n.sent_to factory: :user
    n.team factory: :team
  end
end
