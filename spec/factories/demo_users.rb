FactoryGirl.define do
  sequence(:demo_email_guid) { |n| "#{n}" }

  factory :demo_user do |u|
    u.name { fg_name }
    u.mobile_number { fg_mobile_number }
    u.email { fg_email(name, generate(:demo_email_guid)) }
    u.password "password"
    u.password_confirmation { password }
    u.time_zone "Europe/London"
    u.country "GB"
    u.association :profile, :factory => :user_profile

    after :create do |u, evaluator|
      u.add_role(RoleEnum::REGISTERED)
      u.ensure_authentication_token!
    end
  end
end