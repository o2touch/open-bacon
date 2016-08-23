FactoryGirl.define do
  factory :event do |e|
    e.title { fg_title }
    e.game_type { fg_game_type }
    e.location 
    e.time TimeEnum::NEXT_MONTH
    e.user
    e.team nil
    e.status EventStatusEnum::NORMAL
    e.time_zone 'America/Los_Angeles'

    trait :with_players do |e|
      ignore do
        player_count 5 
      end

      after :create do |e, eval|
        e.teamsheet_entries FactoryGirl.create_list(:teamsheet_entry, eval.player_count, event: e)
        e.reload
      end
    end

    trait :with_messages do |e|
      ignore do
        message_count 2
        player_count 5
      end

      after :create do |e, eval|
        e.messages FactoryGirl.create_list(:event_message_with_comments, eval.message_count, user_list: e.users, messageable: e)
        e.reload
      end
    end

    factory :event_with_players,  traits: [:with_players]
    factory :event_with_messages, traits: [:with_players, :with_messages]
  end

end