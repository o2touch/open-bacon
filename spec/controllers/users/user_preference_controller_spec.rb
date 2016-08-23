require 'spec_helper'

describe UserPreferenceController, :type => :controller do
  describe "#show" do
    context "logged out follower" do
      let(:team) do
        t = FactoryGirl.create(:team)
      end
      
      let(:follower) do
        u = FactoryGirl.create(:user)
        team.add_follower(u)
        u
      end

      let(:player) do
        p = FactoryGirl.create(:user)
        team.add_player(p)
        p
      end

      it 'logged out follower should get logged in' do
        get :show, :token => follower.incoming_email_token, :team_id => team.id
        response.status.should == 200
        User.find(session["warden.user.user.key"][0][0]).should == follower #Check follower is logged in
        sign_out follower
      end

      it 'logged out non-follower should not get logged in' do
        player = FactoryGirl.create(:user)
        get :show, :token => player.incoming_email_token, :team_id => team.id
        response.status.should == 200
        session["warden.user.user.key"].should be_nil #No one logged in
      end

      it 'logged in follower should remain logged in' do
        as_user(follower) do
          get :show, :token => follower.incoming_email_token, :team_id => team.id
        end

        subject.current_user.should == follower
        response.status.should == 200
      end

      it 'should raise an error if the user is non existant' do
        get :show, :token => "token", :team_id => team.id
        response.status.should == 404
      end

      it 'should raise an error if the team is non existant' do
        get :show, :token => "token", :team_id => 10
        response.status.should == 404
      end
    end
  end
end
