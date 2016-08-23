require 'spec_helper'
require 'sidekiq/testing'

describe JuniorMailerService, :sidekiq => false do
  it 'deliver to parents who mail should be sent to' do
    parent_a = mock_model(User)
    parent_a.stub(:should_send_email?).and_return(true)
    parent_b = mock_model(User)
    parent_b.stub(:should_send_email?).and_return(false)

    junior = mock_model(JuniorUser)
    junior.stub(:parents).and_return([parent_a, parent_b])

    
    JuniorMailer.should_receive(:mail).once.with(parent_a.id, junior.id, 1, "two", { :three => 4.0 })
    
    JuniorMailerService.send(:deliver, :mail, junior, 1, "two", { :three => 4.0 })
  end
end
