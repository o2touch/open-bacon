require 'spec_helper'

# TODO Create API::V1::TeamsController and remove String from below
describe TeamsController, type: :controller do
  
  describe '#show' do
    def do_show(id=1)
      get :show, id: id
    end

    before :each do
      @team = FactoryGirl.build(:team)
      @team.id = 1
      @team.stub!(open_invite_link: "hi")
      Team.stub(find: @team)
      fake_ability

      controller.stub(:change_domain_for_tenanted_model?).and_return([false,nil])

    end

    context 'authentication' do
      it 'is not performed' do
        mock_ability(read: :fail)
        signed_out
        do_show
        response.status.should eq(200)
        response.should render_template("show_public")
      end
    end

    context 'authorization' do
      it 'read is checked and returns 200 and renders show_public not authed' do
        mock_ability(read: :fail)
        do_show
        response.status.should eq(200)
        response.should render_template("show_public_restricted")
      end

      it 'read is checked and returns 200 if authed' do
        mock_ability(read: :pass)
        do_show
        response.status.should eq(200)
        response.should render_template("show_private")
      end
    end

    context 'arguments' do
      it 'returns 404 if no record' do
        Team.unstub(:find)
        do_show
        response.status.should eq(404)
      end
    end
  end 
end