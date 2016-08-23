require 'spec_helper'

describe ApplicationController do

	utm_params = {
		utm_source: "source",
		utm_medium: "medium",
		utm_term: "term",
		utm_content: "content",
		utm_campaign: "campaign"
	}

	context 'utm data creation' do
		controller(ApplicationController) do
			skip_authorization_check only: :index
			def index
				render text: "hi"
			end
		end

		it 'puts utm data in the session' do
			get :index, utm_params

			session['utm_data'].should_not be_nil
			session['utm_data'].source.should eq("source")
			session['utm_data'].campaign.should eq("campaign")
		end

		it 'does not overwrite utm session data' do
			utm = UtmData.new
			utm.referer = "TIM"
			session['utm_data'] = utm

			get :index, utm_params

			session['utm_data'].should_not be_nil
			session['utm_data'].referer.should eq("TIM")
		end

		it 'does not set utm data if the user is logged in' do
			sign_in FactoryGirl.create(:user)

			get :index, utm_params

			session['utm_data'].should be_nil
		end
	end

	describe "#change_domain_for_tenanted_model?" do

		context "when on mitoo.co domain" do

			before :each do
				controller.request.host = "mitoo.co"
			end

			it "returns true" do

				tenant_host = "o2touch.mitoo.co"

				@team = mock_model(Team)
				@team.stub(:is_mitoo_team?).and_return(false)
				@team.stub(:tenant).and_return(@tenant)
				@team.stub(:get_tenant_domain).and_return(tenant_host)

				controller.change_domain_for_tenanted_model?(@team).should == [true, tenant_host]
			end

			it "returns false" do

				tenant_host = "mitoo.co"

				@team = mock_model(Team)
				@team.stub(:is_mitoo_team?).and_return(false)
				@team.stub(:tenant).and_return(@tenant)
				@team.stub(:get_tenant_domain).and_return(tenant_host)

				controller.change_domain_for_tenanted_model?(@team).should == [false, nil]
			end
		end

		context "when on any-subdomain.mitoo.co domain" do

			before :each do
				controller.request.host = "any-subdomain.mitoo.co"
			end

			it "returns true" do

				tenant_host = "mitoo.co"

				@team = mock_model(Team)
				@team.stub(:is_mitoo_team?).and_return(false)
				@team.stub(:tenant).and_return(@tenant)
				@team.stub(:get_tenant_domain).and_return(tenant_host)

				controller.change_domain_for_tenanted_model?(@team).should == [true, tenant_host]
			end

			it "returns false" do

				tenant_host = "any-subdomain.mitoo.co"

				@team = mock_model(Team)
				@team.stub(:is_mitoo_team?).and_return(false)
				@team.stub(:tenant).and_return(@tenant)
				@team.stub(:get_tenant_domain).and_return(tenant_host)

				controller.change_domain_for_tenanted_model?(@team).should == [false, nil]
			end
		end

		context "when on a staging domain any-subdomain.stg1.mitoo.co domain" do

			before :each do
				controller.request.host = "any-subdomain.stg1.mitoo.co"
			end

			it "returns true" do

				tenant_host = "stg1.mitoo.co"

				@team = mock_model(Team)
				@team.stub(:is_mitoo_team?).and_return(false)
				@team.stub(:tenant).and_return(@tenant)
				@team.stub(:get_tenant_domain).and_return(tenant_host)

				controller.change_domain_for_tenanted_model?(@team).should == [true, tenant_host]
			end

			it "returns false" do

				tenant_host = "any-subdomain.stg1.mitoo.co"

				@team = mock_model(Team)
				@team.stub(:is_mitoo_team?).and_return(false)
				@team.stub(:tenant).and_return(@tenant)
				@team.stub(:get_tenant_domain).and_return(tenant_host)

				controller.change_domain_for_tenanted_model?(@team).should == [false, nil]
			end
		end

	end

	describe '#set_exclude_from_analytics' do

			context "when no logged-in user" do
				before(:each) do
					controller.stub(:current_user).and_return(nil)
				end

				it "is false" do
					exclude = controller.set_exclude_from_analytics

					exclude.should be_false
				end
			end

			context "when logged-in user has a mitoo email address" do
				before(:each) do

					@mitoo_user = mock_model(Team)
					@mitoo_user.stub(:email).and_return("user@bluefields.com")

					controller.stub(:current_user).and_return(@mitoo_user)
				end

				it "is true" do
					exclude = controller.set_exclude_from_analytics

					exclude.should be_true
				end
			end

			context "when logged-in user does not have a mitoo email address" do
				before(:each) do

					@mitoo_user = mock_model(Team)
					@mitoo_user.stub(:email).and_return("user@gmail.com")

					controller.stub(:current_user).and_return(@mitoo_user)
				end
				
				it "is false" do
					exclude = controller.set_exclude_from_analytics

					exclude.should be_false
				end
			end

			context "when ip address is a mitoo one" do
				before(:each) do
					@request.env['REMOTE_ADDR'] = '68.108.56.31'
				end

				it "is true" do
					exclude = controller.set_exclude_from_analytics

					exclude.should be_true
				end
			end

			context "when ip address is not a mitoo one" do
				before(:each) do
					@request.env['REMOTE_ADDR'] = '1.2.3.4'
				end

				it "is false" do
					exclude = controller.set_exclude_from_analytics

					exclude.should be_false
				end
			end

			context "when user agent string is a browser" do
				before(:each) do
					@request.env['HTTP_USER_AGENT'] = 'Mozilla/5.0 (Windows NT 6.3; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/37.0.2049.0 Safari/537.36'
				end

				it "is false" do
					exclude = controller.set_exclude_from_analytics

					exclude.should be_false
				end
			end

			context "when user agent string is a spider" do
				before(:each) do
					@request.env['HTTP_USER_AGENT'] = 'Mozilla/5.0 (compatible; bingbot/2.0; +http://www.bing.com/bingbot.htm'
				end

				it "is true" do
					exclude = controller.set_exclude_from_analytics

					exclude.should be_true
				end
			end
	end
end