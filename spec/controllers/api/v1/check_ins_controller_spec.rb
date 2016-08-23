require 'spec_helper'

describe Api::V1::CheckInsController do

	before :each do
		# This stubs out the before_filter of application_controller
		Api::V1::CheckInsController.any_instance.stub(:log_user_activity)
	end

	describe '#create' do
		before :each do
			@tse = FactoryGirl.create :teamsheet_entry
			signed_in
			fake_ability
		end

		def do_create(attrs=nil)
			post :create, id: @tse.id, format: :json 
		end

		context 'authentication' do
			it 'is performed' do
				signed_out
				do_create
				response.status.should eq(401)
			end
		end

		context 'authorization' do
			it 'read is checked and returns 401 if not authed' do
				mock_ability(check_in: :fail)
				do_create
				response.status.should eq(401)
			end

			it 'read is checkout and returns 200 if authed' do
				mock_ability(check_in: :pass)
				do_create
				response.status.should eq(200)
			end
		end

		context 'arguments' do
			it 'returns 404 if no record' do
				post :create, id: 1927834, format: :json 
				response.status.should eq(404)
			end
		end

		context 'functionality' do
			it 'does shit' do
				TeamsheetEntriesService.should_receive(:check_in).with(@tse)
				do_create
				response.status.should eq(200)
			end
		end
	end


	describe '#destroy' do
		before :each do
			@tse = FactoryGirl.create :teamsheet_entry
			signed_in
			fake_ability
		end

		def do_destroy(attrs=nil)
			post :destroy, id: @tse.id, format: :json 
		end

		context 'authentication' do
			it 'is performed' do
				signed_out
				do_destroy
				response.status.should eq(401)
			end
		end

		context 'authorization' do
			it 'read is checked and returns 401 if not authed' do
				mock_ability(check_in: :fail)
				do_destroy
				response.status.should eq(401)
			end

			it 'read is checkout and returns 200 if authed' do
				mock_ability(check_in: :pass)
				do_destroy
				response.status.should eq(200)
			end
		end

		context 'arguments' do
			it 'returns 404 if no record' do
				post :create, id: 1927834, format: :json 
				response.status.should eq(404)
			end
		end

		context 'functionality' do
			it 'does shit' do
				TeamsheetEntriesService.should_receive(:check_out).with(@tse)
				do_destroy
				response.status.should eq(200)
			end
		end
	end

	describe '#bulk' do
		before :each do
			@tses = []
			(1..5).each do
				@tses << FactoryGirl.create(:teamsheet_entry)
			end

			signed_in
			fake_ability
		end

		def do_bulk(attrs=nil)
			json = {}
			@tses.each do |tse|
				json[tse.id] = (tse.id%2).to_s
			end

			post :bulk, check_ins: json, format: :json 
		end

		context 'authentication' do
			it 'is performed' do
				signed_out
				do_bulk
				response.status.should eq(401)
			end
		end

		context 'authorization' do
			it 'check_in is checked and returns 401 if not authed' do
				mock_ability(check_in: :fail)
				do_bulk
				response.status.should eq(401)
			end

			it 'check_in is checked and returns 200 if authed' do
				mock_ability(check_in: :pass)
				do_bulk
				response.status.should eq(200)
			end
		end

		context 'arguments' do
			it 'returns 404 if no record' do
				post :bulk, check_ins: {1927834 => '1'}, format: :json 
				response.status.should eq(404)
			end
			it 'returns 422 if no check ins sent' do
				post :bulk, hi: "lolz", format: :json 
				response.status.should eq(422)
			end
			it 'returns 422 if check ins empty' do
				post :bulk, check_ins: {}, format: :json 
				response.status.should eq(422)
			end
			it 'returns 422 if status invalid' do
				post :bulk, check_ins: {1 => "HI!!!!1!"}, format: :json 
				response.status.should eq(422)
			end
		end

		context 'functionality' do
			it 'does shit' do
				TeamsheetEntriesService.should_receive(:check_out).exactly(2).times
				TeamsheetEntriesService.should_receive(:check_in).exactly(3).times
				do_bulk
				response.status.should eq(200)
			end
		end
	end
end