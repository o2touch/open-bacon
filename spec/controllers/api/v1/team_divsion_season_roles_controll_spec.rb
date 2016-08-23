# this is copied and pasted fixture tests.


# require 'spec_helper'

# describe Api::V1::TeamDivisionSeasonrolesController do

# 	describe '#create' do
# 		before :each do
# 			@division = FactoryGirl.create :division_season
# 			@team = FactoryGirl.create :team

# 			signed_in
# 			fake_ability
# 		end

# 		def do_create(attrs=nil)
# 			fx = FactoryGirl.attributes_for :fixture
# 			fx.merge! attrs unless attrs.nil?

# 			post :create, fixture: fx, api_v1_division_id: 1, format: :json 
# 		end

# 		context 'authentication' do
# 			it 'is performed' do
# 				signed_out
# 				do_create
# 				response.status.should eq(401)
# 			end
# 		end

# 		context 'authorization' do
# 			it 'read is checked and returns 401 if not authed' do
# 				mock_ability(manage: :fail)
# 				do_create
# 				response.status.should eq(401)
# 			end

# 			it 'read is checkout and returns 200 if authed' do
# 				mock_ability(manage: :pass)
# 				do_create
# 				response.status.should eq(200)
# 			end
# 		end

# 		context 'arguments' do
# 			it 'returns 404 if no record' do
# 				post :create, fixture: {}, api_v1_division_id: 1242143234, format: :json 
# 				response.status.should eq(404)
# 			end
# 		end

# 		context 'functionality' do
# 			it 'does shit' do
# 				#shittest #needsstubbing #doyouliveinthe90s? #howevershitisfucked
# 				@controller.should_receive(:process_location_json)
# 				lambda { do_create }.should change(Fixture, :count).by(1)
# 				response.status.should eq(200)
# 			end

# 			# TODO: fix. TS
# 			# it 'sets edit_mode on the div to 1' do
# 			# 	@division.should_receive(:update_attributes!).with({edit_mode: 1})
# 			# 	do_create
# 			# end
# 		end
# 	end