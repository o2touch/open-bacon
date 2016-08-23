require 'spec_helper'

describe TeamsheetEntriesService do
	describe 'checking in/out' do
		before :each do
			@tse = FactoryGirl.create :teamsheet_entry
		end

		it 'should check someone in' do
			TeamsheetEntriesService.check_in(@tse)

			@tse.checked_in.should be_true
			@tse.checked_in_at.should_not be_nil
		end
		it 'should check someone out' do #waaaaaaay!
			@tse.checked_in = true
			@tse.checked_in_at = Time.now

			TeamsheetEntriesService.check_out(@tse)

			@tse.checked_in.should be_false
			@tse.checked_in_at.should be_nil
		end
	end
end