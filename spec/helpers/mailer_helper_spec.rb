require 'spec_helper'

describe MailerHelper do
	describe '#determine_mail_from_for_automated_email' do
		it 'should be the do not reply address if no email' do
			determine_mail_from_for_automated_email(Tenant.find(1)).should eq("Mitoo <do_not_reply@mitoo.co>")
		end
		it 'should be the do not reply address and correct tenant' do
			determine_mail_from_for_automated_email(Tenant.find(2)).should eq("O2 Touch via Mitoo <do_not_reply@mitoo.co>")
		end
		it 'should be the supplied address if email' do
			determine_mail_from_for_automated_email(Tenant.find(1), "tim@gmail.org.uk").should eq("Mitoo <tim@gmail.org.uk>")
		end
		it 'should be the supplied address if email and tenant' do
			determine_mail_from_for_automated_email(Tenant.find(2), "tim@gmail.org.uk").should eq("O2 Touch via Mitoo <tim@gmail.org.uk>")
		end
	end

	describe '#determine_mail_from_for_user_email' do
		it "should be the user's name, with the notifications address" do
			user = double(name: "Timothy P Sherratt")
			determine_mail_from_for_user_email(user).should eq("Timothy P Sherratt <notifications@mitoo.co>")
		end
	end

	describe '#determine_mail_from_for_team' do
		before :each do
			@helper = Object.new.extend MailerHelper
		end
		it 'should return user dets if, user supplied' do
			@user = double("user")
			@helper.should_receive(:format_email_from_user).with(@user)
			@helper.determine_mail_from_for_team(nil, @user)
		end
		it 'should return league dets if team in league' do
			@team = double("team")
			@league = double("league")
			@team.stub(:primary_league).and_return(@league)
			@team.stub(:league?).and_return(true)
			@helper.should_receive(:format_email_from_league).with(@league)
			@helper.determine_mail_from_for_team(@team)
		end
		it 'should return founder dets if neither of the above' do
			@team = double(founder: "HIIIII")
			@team.stub(:league?).and_return(false)
			@helper.should_receive(:format_email_from_user).with("HIIIII")
			@helper.determine_mail_from_for_team(@team)
		end
	end

	describe '#determine_mail_from_for_event' do
		it 'should get it from the team' do
			@helper = Object.new.extend MailerHelper
			@event = double(team: "team")
			@user = double("user")

			@helper.should_receive(:determine_mail_from_for_team).with("team", @user)
			@helper.determine_mail_from_for_event(@event, @user)
		end
	end

	describe '#determine_mail_from_for_general_notifications' do
		it 'should be the notifications address' do
			determine_mail_from_for_general_notifications(Tenant.find(1)).should eq("Mitoo <notifications@mitoo.co>")
		end
		it 'should be the notifications address from the tenant' do
			determine_mail_from_for_general_notifications(Tenant.find(2)).should eq("O2 Touch via Mitoo <notifications@mitoo.co>")
		end
	end

	describe '#format_email_from_user' do
		it 'should be from the user, with the name' do
			@user = FactoryGirl.build(:user, name: "Timothy P Sherratt", email: "tim@gmail.org.uk")
			format_email_from_user(@user).should eq("Timothy P Sherratt <tim@gmail.org.uk>")
		end
	end

	describe '#format_email_from_league' do
		it 'should have league title, and DNR address' do
			@league = FactoryGirl.build(:league, title: "Choice League, Bru, NZ")
			format_email_from_league(@league).should eq("Choice League, Bru, NZ via Mitoo <do_not_reply@mitoo.co>")
		end
	end

	describe '#format_email_to_user' do
		it 'should have their name and email address. cool man.' do
			@user = FactoryGirl.build(:user, name: "Timothy P Sherratt", email: "tim@gmail.org.uk")
			format_email_to_user(@user).should eq("Timothy P Sherratt <tim@gmail.org.uk>")
		end
	end
end