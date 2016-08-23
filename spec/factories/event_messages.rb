FactoryGirl.define do
	factory :event_message do |m|
		ignore do
			user_list { [FactoryGirl.create(:user)] }
		end

		m.text { fg_lorem }
		m.user { user_list.sample }

		association :messageable, :factory => :event

		after :create do |m, eval| 
			EventMessageHelper.new.create_activity_item(m)
		end

		trait :with_comments do
			ignore do
				comment_count 2
			end

			after :create do |m, eval|
				m.activity_item.comments FactoryGirl.create_list(:activity_item_comment, eval.comment_count, user_list: eval.user_list, activity_item: m.activity_item)
			end
		end

		factory :event_message_with_comments, traits: [:with_comments]
	end

	factory :activity_item_comment do |c|
		ignore do
			user_list { [FactoryGirl.create(:user)] }
		end
		c.user { user_list.sample }
		text { fg_lorem 4 }
		activity_item nil
	end
end
	