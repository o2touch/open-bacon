FactoryGirl.define do
  factory :guest_role, class: "Role" do |r|
    r.name "Guest"
  end
  
  factory :registered_role, class: "Role" do |r|
    r.name "Registered"
  end
end