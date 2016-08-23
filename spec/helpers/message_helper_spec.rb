require 'spec_helper'

include MessageHelper

describe "formatted_recipients" do 
  def build_mock_user(id, name, username)
    user = mock_model(User)
    user.stub(:id).and_return(id)
    user.stub(:name).and_return(name)
    user.stub(:username).and_return(username)
    User.should_receive(:find).with(id).and_return(user) 
    user
  end

  it 'returns the enriched recipients hash' do
    user_one = build_mock_user(1, "one", "uone")
    user_two = build_mock_user(2, "two", "utwo")
    user_three = build_mock_user(3, "three", "uthree")

    recipients = {
      'users' => [1,2,3],
      'groups' => [5,6,7]
    }
    
    formatted_recipients(recipients).should == { 
      "users" => [
        {"id"=>1, "name"=>"one", "username"=>"uone"}, 
        {"id"=>2, "name"=>"two", "username"=>"utwo"}, 
        {"id"=>3, "name"=>"three", "username"=>"uthree"}
      ],
      "groups" => [5,6,7]
    }
  end
end