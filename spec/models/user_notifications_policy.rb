require 'spec_helper'

describe UserNotificationsPolicy do

  describe "#should_notify?" do
  
    context "for registered mitoo users" do
      it "is returns true" do
        user = FactoryGirl.create :user, name: "Alfredo", invited_by_source: "MITOO"
        user.stub(:role?).with("Registered").and_return(true)
        unp = UserNotificationsPolicy.new(user)

        unp.should_notify?.should == true
      end
    end

    context "for invited mitoo users" do
      it "is returns false" do
        user = FactoryGirl.create :user, name: "Alfredo", invited_by_source: "MITOO"
        user.stub(:role?).with("Registered").and_return(false)
        unp = UserNotificationsPolicy.new(user)

        unp.should_notify?.should == false
      end
    end

    context "for other users" do
      it "is returns true" do
        user = FactoryGirl.create :user, name: "Alfredo"
        user.stub(:role?).with("Registered").and_return(true)
        unp = UserNotificationsPolicy.new(user)

        unp.should_notify?.should == true
      end

      it "is returns true" do
        user = FactoryGirl.create :user, name: "Alfredo"
        user.stub(:role?).with("Registered").and_return(false)
        unp = UserNotificationsPolicy.new(user)

        unp.should_notify?.should == true
      end
    end

  end

end