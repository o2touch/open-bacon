FactoryGirl.define do	
  factory :team do |t|
    t.name { fg_team_name }
    t.sport { fg_sport }
    t.created_by factory: :user
    t.association :profile, :factory => :team_profile
    t.demo_mode 0
    t.slug {name.gsub(' ','-').downcase}

    factory :junior_team do |jt|
      before :create do |jt, evaluator|
        jt.profile.update_attributes(age_group: AgeGroupEnum::UNDER_10)        
      end
    end

    after :create do |t, evaluator|
        t.profile.update_attributes(:sport => t.sport)
        unless t.created_by.nil?
          t.add_organiser(t.created_by)
          if  t.profile.age_group > AgeGroupEnum::UNDER_13
            t.add_player(t.created_by)
          end
        end
    end

    trait :with_players do |t|
      ignore do
        player_count 11
      end

      after :create do |t, evaluator|
        if t.profile.age_group <= AgeGroupEnum::UNDER_13
          # juniors
          FactoryGirl.create_list(:junior_user, evaluator.player_count).each do |u|
            TeamUsersService.add_player(t, u, false, false)
            TeamUsersService.add_parent(t, u.parents.first, false)
          end
        else
          # adults
          FactoryGirl.create_list(:user, evaluator.player_count).each do |u|
            TeamUsersService.add_player(t, u, false, false)
          end
        end
      end
    end

    trait :with_followers do |t|
      ignore do
        player_count 11
      end

      after :create do |t, evaluator|         
        FactoryGirl.create_list(:user, evaluator.player_count).each do |u|
          TeamUsersService.add_follower(t, u)
        end
      end
    end

    trait :with_events do |t|
      ignore do
        event_count 5
      end
      after :create do |t, evaluator|
        t.events FactoryGirl.create_list(:event, evaluator.event_count, user: t.created_by, team: t, time: 2.weeks.from_now)
      end
    end
  end

end
