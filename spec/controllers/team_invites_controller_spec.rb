require 'spec_helper'

include TeamUrlHelper

describe TeamInvitesController, :type => :controller  do
  describe '#show' do
    context 'faft team' do
      before :each do
        @team_invite = FactoryGirl.build(:team_invite)
        @team = @team_invite.team
        @team.stub(:source_id).and_return(999)
        @division = FactoryGirl.build(:division_season)
        @division.source_id = 101
        @team_invite.team.stub(:divisions).and_return([@division])
        
        TeamInvite.stub(:find_by_token).and_return(@team_invite)

        get :show, token: "whatever", format: :html
      end

      it 'returns 302' do
        response.status.should eq(302)
      end
      it 'redirects to faft unclaimed team page' do
        response.should redirect_to default_team_path(@team)
      end
    end

    context 'team' do
      before :each do
        @team_invite = FactoryGirl.build(:team_invite)
        @team = @team_invite.team
        TeamInvite.stub(:find_by_token).and_return(@team_invite)
        get :show, token: "whatever", format: :html
      end

      it 'returns 302' do
        response.status.should eq(302)
      end
      it 'redirects to faft unclaimed team page' do
        response.should redirect_to team_path(@team)
      end
    end
  end
end
