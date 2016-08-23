require 'spec_helper'

describe ProductionMailInterceptor, ".deliver?" do
  it "is false if user shouldn't recieve emails" do
    email = 'andy@bf.com'
    user = mock_model(User, :email => email, :should_send_email? => false)
    
    User.should_receive(:where).once.with({:email => email}).and_return([user])

    message = mock(to: "#{email}")
    ProductionMailInterceptor.deliver?(message).should be_false
  end

  it "is false if user shouldn't recieve emails and users email contain users name" do
    email = 'andy@bf.com'
    user = mock_model(User, :name => 'andy', :email => email, :should_send_email? => false)
    
    User.should_receive(:where).once.with({:email => email}).and_return([user])

    message = mock(to: "#{user.name} <#{user.email}>")
    ProductionMailInterceptor.deliver?(message).should be_false
  end

  it "is true if user should recieve emails" do
    email = 'andy@bf.com'
    user = mock_model(User, :email => email, :should_send_email? => true)
    
    User.should_receive(:where).once.with({:email => email}).and_return([user])

    message = mock(to: "#{email}")
    ProductionMailInterceptor.deliver?(message).should be_true
  end
end
