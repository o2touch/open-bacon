FactoryGirl.define do
    factory :junior_user do |j|
        j.email nil
        j.password nil	
        j.name { fg_junior_name }
        j.mobile_number nil
        j.time_zone "Europe/London"
        j.country "GB"
        j.association :profile, :factory => :user_profile
        j.dob 9.years.ago
        after :create do |j, evaluator|
            j.add_role(RoleEnum::INVITED)

            if evaluator.parent
                j.associate_parent(evaluator.parent)
            end

            if evaluator.parents
                evaluator.parents.each do |x|
                    j.associate_parent(x)
                end
            end
            
            if !evaluator.parents && !evaluator.parent
              j.associate_parent(FactoryGirl.create(:user))
            end
        end

        ignore do
            parent nil
            parents nil
        end
    end
end