require 'spec_helper'

describe Api::V1::ActivityItemCommentsController do
	before :each do
		@user = FactoryGirl.create :user
    request.env['X-AUTH-TOKEN'] = @user.authentication_token
    @team = FactoryGirl.create :team
    @event = FactoryGirl.create :event_with_messages, user: @user, team:@team, message_count: 1, player_count: 2
    @message = @event.messages.first
    @activity_item = @message.activity_item
	end

	describe '#create', type: :api do
		def do_create
			comment_attrs = { text: "some comment text" }
			post :create, format: :json, api_v1_activity_item_id: @activity_item.id, activity_item_comment: comment_attrs
		end

		context 'adding a comment' do
			it 'responds with 200' do
				do_create
				response.status.should eq 200
			end

			it 'returns that comment'

			it 'creates the message on the event' do
				lambda { do_create }.should change(@activity_item.comments, :count).by(1)
			end
		end	
	end

	describe '#show', type: :api do
		it 'responds with 501' do
			get :show, api_v1_activity_item_id: 1, id: 1
			response.status.should eq(501)
		end
	end

	describe '#update', type: :api do
		it 'responds with 501' do
			put :update, api_v1_activity_item_id: 1, id: 1
			response.status.should eq(501)
		end
	end

	describe '#destroy', type: :api do
		it 'responds with 501' do 
			delete :destroy, api_v1_activity_item_id: 1, id: 1
			response.status.should eq(501)
		end
	end
end
