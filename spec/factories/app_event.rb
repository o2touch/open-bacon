FactoryGirl.define do
  factory :app_event do |n|
    n.verb 'created'
    n.processed_at nil
    n.created_at Time.now
    n.updated_at Time.now
    n.meta_data {}
    n.subj factory: :user
    n.obj factory: :event
  end
end
