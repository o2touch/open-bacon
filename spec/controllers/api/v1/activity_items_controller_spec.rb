require 'spec_helper'

describe Api::V1::ActivityItemsController, :redis => true do
	before :each do

		# This stubs out the before_filter of application_controller
		Api::V1::ActivityItemsController.any_instance.stub(:log_user_activity)

		@user = double("user")
		@user.stub(class: User)
		@user.stub(profile_feed: [])
		@user.stub(newsfeed: [])
		User.stub(find_by_id: @user)

		@event = double("event")
		@event.stub(class: Event)
		@event.stub(activity_feed: [])
		Event.stub(find_by_id: @event)

		signed_in
		fake_ability
	end

	describe '#index' do

		def do_index(feed_type="profile", id=1)
		  get :index, format: :json, user_id: id, feed_type: feed_type, item_count: 5
		end

		def do_index_event(feed_type="activity", id=1)
		  get :index, format: :json, event_id: id, feed_type: feed_type, item_count: 5
		end

		# This just checks that authentication is not skipped for an action
		# 	not that it actually works.
		context 'authentication' do
			it 'is performed' do
				signed_out
				do_index
				response.status.should eq(401)
			end
		end

		context 'find owner' do
			it 'returns 422 if request is missing owner id' do
		 	 	get :index, format: :json, feed_type: :activity, item_count: 5
				response.status.should eq 422
			end

			it 'returns 422 if request is for an invalid owner type' do
		  	get :index, format: :json, random_id: 1, feed_type: :activity, item_count: 5
				response.status.should eq 422
			end

			it 'returns 422 if owner does not exist' do
				Event.stub(find_by_id: nil)
				get :index, format: :json, event_id: 100, feed_type: :activity, item_count: 5
				response.status.should eq 422
			end
		end

		context 'authorization' do
			it 'responds with 401 if not authorized' do
				mock_ability(read_private_details: :fail)
				do_index
			  response.status.should eq(401)
			end

			it 'responds with 200 if authorized' do
				mock_ability(read_private_details: :pass)
				@user.should_receive(:get_mobile_feed).and_return([[]])
				do_index
			  response.status.should eq(200)
			end
		end

		context 'with valid params' do
			context 'when requesting a users profile feed' do
				it 'responds with 200' do
					@user.should_receive(:get_mobile_feed).once.with("profile", nil, nil, anything, nil).and_return([[]])
					do_index("profile")
					response.status.should eq(200)
				end
				it 'calls profile_feed() on the correct user' do
					@user.should_receive(:get_mobile_feed).once.with("profile", nil, nil, anything, nil).and_return([[]])
					do_index
				end
			end
			context 'when requesting a users newsfeed' do
				it 'responds with 200' do
					@user.should_receive(:get_mobile_feed).once.with("newsfeed", nil, nil, anything, nil).and_return([[]])
					do_index("newsfeed")
					response.status.should eq(200)
				end
				it 'calls newsfeed() on the correct user' do
					@user.should_receive(:get_mobile_feed).once.with("newsfeed", nil, nil, anything, nil).and_return([[]])
					do_index("newsfeed")
				end
			end
			context 'when requesting an event activity feed' do
				it 'responds with 200' do
					@event.should_receive(:get_mobile_feed).once.with("activity", nil, nil, anything, nil).and_return([[]])
					do_index_event("activity")
					response.status.should eq(200)
				end
				it 'calls activity_feed() on the correct event' do
					@event.should_receive(:get_mobile_feed).once.with("activity", nil, nil, anything, nil).and_return([[]])
					do_index_event("activity")
				end
			end
		end

		context 'with invalid params' do
			context 'when supplying an invalid owner_type' do
				it 'returns 422 (unprocessable entity)' do
					get :index, format: :json, invalid_id: 1, feed_type: 'activity', item_count: 10
					response.status.should eq(422)
				end
			end
			context 'when supplying an invalid owner_id' do
				it 'returns 422 (unprocessable entity)' do
					User.should_receive(:find_by_id).once.with(-1).and_return(nil)
					do_index("newsfeed", -1)
					response.status.should eq(422)
				end
			end
			context 'when supplying an invalid feed_type' do
				it 'returns 422 (unprocessable entity)' do
					do_index("invalid", 1)
					response.status.should eq(422)
				end
			end
		end
	end

	describe '#create' do
		it 'performs authentication' do
			signed_out
			post :create, format: :json
			response.status.should eq(401)
		end
		it 'responds with 501 (not implemented)' do
			post :create, format: :json
			response.status.should eq(501)
		end
	end
	
	describe '#show' do
		it 'performs authentication' do
			signed_out
			get :show, format: :json, id: 1
			response.status.should eq(401)
		end
	end

	describe '#update' do
		it 'performs authentication' do
			signed_out
			put :update, format: :json, id: 1
			response.status.should eq(401)
		end

		it 'responds with 422 if the activity_item cannot be found' do
			put :update, format: :json, id: 100, :params => {}
			response.status.should eq(404)
		end

		it 'raises error if the meta_data cannot be deserialized from JSON' do
			put :update, format: :json, id: 100, :params => {}
			event_message = mock_model(EventMessage)
			event_message.stub(:messageable).and_return(mock_model(Team))
			event_message.stub(:messageable_type).and_return(Team.name)

			meta_data = "bad json string"

			activity_item = mock_model(ActivityItem)
			activity_item.stub(:subj).and_return(mock_model(User))
    	activity_item.stub(:obj).and_return(event_message)
    	activity_item.stub(:obj_type).and_return(EventMessage.name)
    	activity_item.stub(:verb).and_return(:created)
    	activity_item.stub(:meta_data).and_return(meta_data)
    	activity_item.stub(:id).and_return(1)

    	ActivityItem.stub(:cache_find_by_id).and_return(activity_item)

    	expect {
				put :update, format: :json, id: activity_item.id, :meta_data => { 'starred' => true }
			}.to raise_error(JSON::ParserError)
		end

		it 'responds with 200' do
			event_message = mock_model(EventMessage)
			event_message.stub(:messageable).and_return(mock_model(Team))
			event_message.stub(:messageable_type).and_return(Team.name)

			activity_item = mock_model(ActivityItem)
			activity_item.stub(:subj).and_return(mock_model(User))
    	activity_item.stub(:obj).and_return(event_message)
    	activity_item.stub(:obj_type).and_return(EventMessage.name)
    	activity_item.stub(:verb).and_return(:created)
    	activity_item.stub(:meta_data).and_return(nil)
    	activity_item.stub(:id).and_return(1)
    	activity_item.stub(:fetch_from_redis).and_return(nil)

    	ActivityItem.stub(:cache_find_by_id).and_return(activity_item)

			put :update, format: :json, id: activity_item.id, :params => {}

			response.status.should eq(200)
		end

		it 'updates the meta data for messages' do
			#COMMENTED OUT WHILE WE HAVE TIMECOP ISSUES.

			# event_message = mock_model(EventMessage)
			# event_message.stub(:messageable).and_return(mock_model(Team))
			# event_message.stub(:messageable_type).and_return(Team.name)

			# activity_item = mock_model(ActivityItem)
			# activity_item.stub(:subj).and_return(mock_model(User))
   #  	activity_item.stub(:obj).and_return(event_message)
   #  	activity_item.stub(:obj_type).and_return(EventMessage.name)
   #  	activity_item.stub(:verb).and_return(:created)
   #  	activity_item.stub(:meta_data).and_return(nil)
   #  	activity_item.stub(:id).and_return(1)
   #  	activity_item.stub(:fetch_from_redis).and_return(nil)
   #  	activity_item.stub(:save!).and_return(true)

			# params = {
			# 	'meta_data' => {
			# 		'starred' => true,
			# 	}
			# }

			# time = Time.now

			# activity_item.should_receive(:meta_data=).with({
			# 	'starred' => true,
			# 	'starred_at' => time
			# }.to_json).and_return(true)

			# ActivityItem.stub(:cache_find_by_id).and_return(activity_item)

			# Timecop.freeze(time) do
			# 	put :update, format: :json, id: activity_item.id, :meta_data => params['meta_data']
			# end
		end

		it 'updates the starred set in redis' do
			team = FactoryGirl.create(:team)
			user = team.founder
			message = FactoryGirl.create(:event_message, :user => user, :messageable => team)

			activity_item = ActivityItem.new
			activity_item.subj = user
			activity_item.obj = message
			activity_item.verb = :created
			activity_item.save!

			activity_item.push_to_redis(team, :profile)

			params = {
				'meta_data' => {
					'starred' => true,
				}
			}

			put :update, format: :json, id: activity_item.id, :meta_data => params['meta_data']
			
			($redis_store_feeds.zrevrangebyscore team.redis_feed_key(:profile), activity_item.timestamp, activity_item.timestamp).should == [activity_item.id.to_s]
		end
	end

	describe '#show' do
		it 'returns an AI by object type and id' do
			team = FactoryGirl.create(:team)
			user = team.founder
			message = FactoryGirl.create(:event_message, :user => user, :messageable => team)

			activity_item = ActivityItem.new
			activity_item.subj = user
			activity_item.obj = message
			activity_item.verb = :created
			activity_item.save!
			
			get :show, format: :json, obj_id: message.id, obj_type: message.class.name

			response.should be_successful
  		response.should render_template("api/v1/activity_items/show")
		end

		it 'raises error if the object does not exist' do
			get :show, format: :json, obj_id: 99, obj_type: 'EventMessage'

			response.should_not be_successful
		end
	end

	describe '#destroy' do
		it 'performs authentication' do
			signed_out
			delete :destroy, format: :json, id: 1
			response.status.should eq(401)
		end
		it 'responds with 501 (not implemented)' do
			delete :destroy, format: :json, id: 1
			response.status.should eq(501)
		end
	end
end
