FactoryGirl.define do
  sequence(:authorization_name) { |n| "Person Surname #{n}" }

  factory :fb_authorization, :class => "Authorization" do |e|
    e.name { FactoryGirl.generate(:authorization_name) }
    e.provider "Facebook"
    e.uid "1234567"
    e.token "thisisanaccesstoken"
    e.secret "thisisasecret"
    e.link "http://linktoprofile.com"
  end
end