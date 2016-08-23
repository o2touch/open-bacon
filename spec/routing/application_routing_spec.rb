require "spec_helper"

describe "ApplicationRouting" do

  describe "short_profile path helper" do

    context "when user has valid username" do
      let(:user) { u = FactoryGirl.create(:user) }

      it { short_profile_path(user).should == "/" + user.username }
    end

    context "when user does not have a username" do
      let(:user) do
        u = FactoryGirl.create(:user)
        u.username = nil
        u.save
        u
      end

      it { short_profile_path(user).should == "/" + user.id.to_s }
      it { {:get => short_profile_path(user)}.should route_to("users/user_profiles#show", :username => user.id.to_s, "conditions"=>{"method"=>:get}) }
    end
  end

  describe "long_profile path helper" do

    context "when usr has valid username" do
      let(:user) { u = FactoryGirl.create(:user) }

      it { long_profile_path(user).should == "/users/" + user.username }
    end

    context "when user does not have a username" do
      let(:user) do
        u = FactoryGirl.create(:user)
        u.username = nil
        u.save
        u
      end

      it { long_profile_path(user).should == "/users/" + user.id.to_s }
      it { {:get => short_profile_path(user)}.should route_to("users/user_profiles#show", :username => user.id.to_s, "conditions"=>{"method"=>:get}) }
    end
  end  

end