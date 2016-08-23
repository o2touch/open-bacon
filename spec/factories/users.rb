# Read about factories at https://github.com/thoughtbot/factory_girl
FactoryGirl.define do
  sequence(:email_guid) { |n| "#{n}" }
  sequence(:username) { |n| "username#{n}" }

  factory :user do |u|
    u.name { fg_name }
    u.username { generate(:username) }
    u.mobile_number { fg_mobile_number }
    u.email { fg_email(name, generate(:email_guid)) }
    u.password "password"
    u.password_confirmation { password }
    u.time_zone "Europe/London"
    u.country "GB"
    u.incoming_email_token { SecureRandom.hex }
    u.association :profile, :factory => :user_profile

    after :create do |u, evaluator|
      u.add_role(RoleEnum::REGISTERED)
      u.ensure_authentication_token!
    end
  end

  trait :as_invited do |u|
    after :create do |u, evaluator|
      u.add_role(RoleEnum::INVITED)
      u.delete_role(RoleEnum::REGISTERED)
      u.password = nil
      u.password_confirmation = nil
    end
  end

  trait :as_invited_no_email do |u|
    after :build do |u, evaluator|
      u.add_role(RoleEnum::INVITED)
      u.delete_role(RoleEnum::REGISTERED)
      u.email = ""
      u.mobile_number = "+1234567891"
      u.password = nil
      u.password_confirmation = nil
    end
  end

  trait :with_events do |u|
    # event_count is declared as an ignored attribute and available in
    # attributes on the factory, as well as the callback via the evaluator.
    ignore do
      event_count 5
    end
    # The after(:create) yields two values; the user instance itself and the
    # evaluator, which stores all values from the factory, including ignored
    # attributes; `create_list`'s second argument is the number of records
    # to create and we make sure the user is associated properly to the event.
    after :create do |u, evaluator|
      # TODO SR - We shouldn't need to assign here!
      u.events_created FactoryGirl.create_list(:event, evaluator.event_count, :user => u, :team => nil, :time => Time.now + (2*7*24*60*60))
    end
  end

  trait :with_teams do |u|
    ignore do
      team_count 5
    end

    after :create do |u, evaluator|
      teams = FactoryGirl.create_list(:team, evaluator.team_count, :created_by => u)
      teams.each do |x| 
        x.add_organiser(u)
        x.add_player(u)
      end
    end
  end

  trait :with_team_events do |u|
    ignore do
      team_count 5
      team_event_count 1
      team_past_event_count 0
    end

    after :create do |u, evaluator|
      FactoryGirl.create_list(:team, evaluator.team_count, :created_by => u).each do |t|
        t.add_organiser(u)
        t.add_player(u)
        FactoryGirl.create_list(:event, evaluator.team_event_count, :user => u, :team => t, :time => 2.weeks.from_now)
        FactoryGirl.create_list(:event, evaluator.team_past_event_count, :user => u, :team => t, :time => 2.weeks.ago)
      end
    end
  end

  trait :with_mobile_device do |u|
    after :create do |u, evaluator|
      FactoryGirl.create :mobile_device, :user_id => u.id
    end
  end

  trait :with_fb_connected do |u|
    after :create do |u, evaluator|
      FactoryGirl.create(:fb_authorization, :user_id => u.id)
    end
  end
end