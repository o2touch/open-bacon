FactoryGirl.define do
  factory :poly_role do |n|
    n.role_id PolyRole::PLAYER
    n.user factory: :user
    n.obj factory: :team
  end
end
