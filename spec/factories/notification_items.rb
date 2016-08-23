FactoryGirl.define do
  factory :notification_item do |n|
    n.verb 'created'
    n.processed_at nil
    n.created_at Time.now
    n.updated_at Time.now
    n.meta_data {}
    n.subj factory: :user
    n.obj factory: :poly_role
  end
end
