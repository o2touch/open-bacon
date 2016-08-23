require 'spec_helper'

describe SmserHelper do

	context "#mobile_footer_text" do

		before :each do
			@user = FactoryGirl.build(:user)
			@team = FactoryGirl.build(:team)
			@team_invite = FactoryGirl.build(:team_invite, :token => "abcdefghojklmnop")

			TeamInvite.stub(:get_invite).and_return do
				@team_invite
			end
		end

		context "when not registered" do

			before :each do
				@user.stub(:is_registered?).and_return(false)
			end

			it "returns a confirmation link" do
				TeamInvite.should_receive(:get_invite).with(@team, @user)

				text = mobile_footer_text(@user, @team)
				text.should == "Confirm your account: http://test.host/links/team-invite/abcdefghojklmnop"
			end

		end

		context "when registered but not downloaded" do
			
			before :each do
				@user.stub(:is_registered?).and_return(true)
				@user.stub(:mobile_devices).and_return([])
			end

			it "returns a download the app link" do
				text = mobile_footer_text(@user, @team)

				text.should == "Download the app: #{app_download_url}"
			end
		end
	end

	context "#get_short_link" do

		before :each do
			Rails.env.stub(:Production?).and_return(true)
		end

		it "returns a short link" do
			link = "http://test.short/link"
			short_link = get_short_link(link)

			short_link.should_not == link
			short_link.should == "http://bf.tl/1bT24zv"
		end

	end

end