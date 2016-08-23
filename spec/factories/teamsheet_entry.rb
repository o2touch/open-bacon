FactoryGirl.define do  
  factory :teamsheet_entry do |p|
    p.event 
    p.invite_sent Time.now
    p.user

    trait :with_players do |e|
      ignore do
        player_count 5 
      end

      after :create do |e, eval|
        e.teamsheet_entries FactoryGirl.create_list(:teamsheet_entry, eval.player_count, event: e)
        e.reload
      end
    end    
  end
end
