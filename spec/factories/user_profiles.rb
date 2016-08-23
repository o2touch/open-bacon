FactoryGirl.define do	
  factory :user_profile do |u|
    u.bio { fg_lorem(10) }
  end
end