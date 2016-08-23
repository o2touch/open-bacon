require 'spec_helper'

describe Ns2::Processors::Base do
	let(:app_event) do
		AppEvent.new({
			obj: FactoryGirl.build(:event),
			subj: FactoryGirl.build(:user),
			verb: "created",
			meta_data: {}
		})
	end

	describe 'process' do
		before :each do
			Ns2::Processors::Base.stub(respond_to?: true)
			AppEvent.stub(find: app_event)
		end

		it 'should return if the AE has been processed' do
			app_event.processed_at = Time.now
			app_event.should_not_receive(:verb)
			Ns2::Processors::Base.process(1)
		end
		it 'should raise if it cannot process the verb' do
			Ns2::Processors::Base.unstub :respond_to?
			expect{ Ns2::Processors::Base.process(1) }.to raise_error
		end
		it 'should call the verb method on itself' do
			Ns2::Processors::Base.should_receive(:created).with(app_event).and_return([])
			Ns2::Processors::Base.process(1)
		end
		it 'should raise if that method does not return an array' do
			Ns2::Processors::Base.stub(created: nil)
			expect{ Ns2::Processors::Base.process(1) }.to raise_error
		end
		it 'should call process on all nis returned in the array' do
			ni = double("ni")
			ni.should_receive(:process)
			Ns2::Processors::Base.stub(created: [ni])
			Ns2::Processors::Base.process(1)
		end
	end

	describe 'email_ni' do
		it 'should create an ni' do
			EmailNotificationItem.should_receive(:create!)
			Ns2::Processors::Base.email_ni(app_event, User.new, LandLord.default_tenant, "ting", {})
		end
		it 'should set the mailer based on AE.obj' do
			md = {}
			Ns2::Processors::Base.email_ni(app_event, User.new, LandLord.default_tenant, "ting", md)
			md[:mailer].should eq("EventMailer")
		end
		it 'should not set the AE if it has been set' do
			md = { mailer: "BRAP"}
			Ns2::Processors::Base.email_ni(app_event, User.new, LandLord.default_tenant, "ting", md)
			md[:mailer].should eq("BRAP")
		end
	end
end