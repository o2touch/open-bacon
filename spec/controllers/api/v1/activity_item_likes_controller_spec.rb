require 'spec_helper'

describe Api::V1::ActivityItemLikesController do
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
      post :create, format: :json, api_v1_activity_item_id: @activity_item.id
    end

    context 'liking' do
      it 'responds with 200' do
        do_create
        response.status.should eq 200
      end

      it 'creates the like on the event' do
        lambda { do_create }.should change(@activity_item.likes, :count).by(1)
      end
    end

    context 'liking twice' do
      before :each do
        @activity_item.create_like(@user)
      end

      it 'responds with 422' do
        do_create
        response.status.should eq 422
      end

      it 'does not create another like' do
        lambda { do_create }.should change(@activity_item.likes, :count).by(0)
      end
    end 
  end

  describe '#destroy', type: :api do

    before :each do
      @activity_item.create_like(@user)
    end

    def do_delete
      delete :destroy, id: @activity_item.id
    end

    it 'responds with 204' do 
      do_delete
      response.status.should eq(204)
    end

    it 'removes like' do
      expect { do_delete }.to change(@activity_item.likes, :count).by(-1)
    end
  end
end
