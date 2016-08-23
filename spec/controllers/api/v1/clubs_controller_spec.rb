require 'spec_helper'

describe Api::V1::ClubsController do
  render_views

  let(:club){ FactoryGirl.create(:club) }

  describe '#show', type: :api do
    context 'with valid request' do
      def do_show
        get :show, format: :json, id: club.id
      end

      it 'is successful' do
        do_show
        response.status.should eq(200)
      end

      it 'returns the team resource' do
        do_show
        JSON.parse(response.body).fetch("id").should eq(club.id)
      end
    end

    context 'with invalid request' do
      it 'raises a RecordNotFound exception' do
        get :show, format: :json, id: -1
        response.status.should eq(404)
      end
    end
  end
end