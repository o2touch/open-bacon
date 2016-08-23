FactoryGirl.define do
  factory :demo_event do |e|
    e.title { fg_title }
    e.game_type { fg_game_type }
    e.location 
    e.time TimeEnum::NEXT_MONTH
    e.user
    e.team 
    e.status EventStatusEnum::NORMAL
    e.time_zone 'America/Los_Angeles'
  end
end
