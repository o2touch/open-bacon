require 'spec_helper'

describe TeamsheetEntry do
  include SmsSpec::Helpers
  include SmsSpec::Matchers

  context 'Adding a TeamsheetEntry and sending an email' do
    before :each do
      @teamsheet = FactoryGirl.create(:teamsheet_entry)
    end

    it 'sends an sms'
  end
end