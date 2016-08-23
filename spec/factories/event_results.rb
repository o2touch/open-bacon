FactoryGirl.define do
  factory :event_result do |e|
    e.score_for nil
    e.score_against nil 
    e.event
  end
end
