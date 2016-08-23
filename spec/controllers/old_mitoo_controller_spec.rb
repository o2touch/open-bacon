require 'spec_helper'

describe OldMitooController do

	include TeamUrlHelper
	include DivisionUrlHelper

	describe '#handle_routes' do

		context "without page" do
			it "redirects to homepage" do
				get :handle_routes
				response.should redirect_to(root_path)
			end
		end

		context "without id" do
			it "redirects to homepage" do
				get :handle_routes, canvas: nil
				response.should redirect_to(root_path)
			end
		end

		context "without a mdbtid that exists in db" do

			before :each do
				Team.stub(:find_by_mitoo_id).and_return(nil)
			end

			it "redirects to the correct team id" do
				get :handle_routes, canvas: nil
				response.should redirect_to(root_path)
			end
		end

		context "with mdbtid" do

			before :each do
				@team = FactoryGirl.create(:team, source: "MITOO", source_id: 1230)
				Team.stub(:find_by_mitoo_id).and_return(@team)
			end

			it "redirects to team#show from canvas" do
				get :handle_routes, canvas: nil, mdbtid: 1230
				response.should redirect_to(:controller => "teams", :action => "show", :id => @team.id, :omp => :canvas)
			end

			it "redirects to team#show  from results" do
				get :handle_routes, results: nil, mdbtid: 1230
				response.should redirect_to(:controller => "teams", :action => "show", :id => @team.id, :omp => :results)
			end

			it "redirects to team#show  from results" do
				get :handle_routes, table: nil, mdbtid: 1230
				response.should redirect_to(:controller => "teams", :action => "show", :id => @team.id, :omp => :table)
			end

			it "redirects to team#show from stats" do
				get :handle_routes, stats: nil, mdbtid: 1230
				response.should redirect_to(:controller => "teams", :action => "show", :id => @team.id, :omp => :stats)
			end

			it "redirects to team#show from notice" do
				get :handle_routes, notice: nil, mdbtid: 1230
				response.should redirect_to(:controller => "teams", :action => "show", :id => @team.id, :omp => :notice)
			end

			it "redirects to team#show from info" do
				get :handle_routes, info: nil, mdbtid: 1230
				response.should redirect_to(:controller => "teams", :action => "show", :id => @team.id, :omp => :info)
			end

			it "redirects to team#show from followers" do
				get :handle_routes, followers: nil, mdbtid: 1230
				response.should redirect_to(:controller => "teams", :action => "show", :id => @team.id, :omp => :followers)
			end

			it "redirects to team#show from team_fixtures" do
				get :handle_routes, followers: nil, mdbtid: 1230
				response.should redirect_to(:controller => "teams", :action => "show", :id => @team.id, :omp => :followers)
			end

			it "redirects to team#show from team_fixtures" do
				get :handle_routes, team_fixtures: nil, mdbtid: 1230
				response.should redirect_to(:controller => "teams", :action => "show", :id => @team.id, :omp => :team_fixtures)
			end

		end	

		context "with tid" do

			before :each do
				@team = FactoryGirl.create(:team, source: "MITOO", source_id: 1230)
				Mitoo::MitooTeam.stub(:get_mdbid_from_gid).and_return(@team.source_id)
				Team.should_receive(:find_by_mitoo_id).with(@team.source_id).and_return(@team)
			end

			it "redirects to the correct team id" do
				get :handle_routes, canvas: nil, tid: 134567
				response.should redirect_to(:controller => "teams", :action => "show", :id => @team.id, :omp => :canvas)
			end

			it "redirects to the correct team id" do
				get :handle_routes, results: nil, tid: 134567
				response.should redirect_to(:controller => "teams", :action => "show", :id => @team.id, :omp => :results)
			end

			it "redirects to the correct team id" do
				get :handle_routes, table: nil, tid: 134567
				response.should redirect_to(:controller => "teams", :action => "show", :id => @team.id, :omp => :table)
			end

			it "redirects to the correct team id" do
				get :handle_routes, stats: nil, tid: 134567
				response.should redirect_to(:controller => "teams", :action => "show", :id => @team.id, :omp => :stats)
			end

			it "redirects to the correct team id" do
				get :handle_routes, notice: nil, tid: 134567
				response.should redirect_to(:controller => "teams", :action => "show", :id => @team.id, :omp => :notice)
			end

			it "redirects to the correct team id" do
				get :handle_routes, info: nil, tid: 134567
				response.should redirect_to(:controller => "teams", :action => "show", :id => @team.id, :omp => :info)
			end

			it "redirects to the correct team id" do
				get :handle_routes, followers: nil, tid: 134567
				response.should redirect_to(:controller => "teams", :action => "show", :id => @team.id, :omp => :followers)
			end

		end

		context "without a did that exists in db" do

			before :each do
				DivisionSeason.stub(:find_by_mitoo_id).and_return(nil)
			end

			it "redirects to the correct team id" do
				get :handle_routes, canvas: nil
				response.should redirect_to(root_path)
			end
		end

		context "with did" do

			before :each do
				@league = FactoryGirl.create(:league)
				@division = FactoryGirl.create(:division_season, source: "MITOO", source_id: 1230, :league => @league)
				Mitoo::MitooDivision.stub(:get_mdbid_from_gid).and_return(@division.source_id)
				DivisionSeason.should_receive(:find_by_mitoo_id).with(@division.source_id).and_return(@division)
			end

			it "redirects to division#show from league" do
				get :handle_routes, league: nil, did: 1230
				response.should redirect_to(default_division_path(@division, :omp => :league))
			end

			it "redirects to division#show  from league_results" do
				get :handle_routes, league_results: nil, did: 1230
				response.should redirect_to(default_division_path(@division, :omp => :league_results))
			end

			it "redirects to division#show  from league_fixtures" do
				get :handle_routes, league_fixtures: nil, did: 1230
				response.should redirect_to(default_division_path(@division, :omp => :league_fixtures))
			end

			it "redirects to division#show  from league_table" do
				get :handle_routes, league_table: nil, did: 1230
				response.should redirect_to(default_division_path(@division, :omp => :league_table))
			end

			it "redirects to division#show from league_scorers" do
				get :handle_routes, league_scorers: nil, did: 1230
				response.should redirect_to(default_division_path(@division, :omp => :league_scorers))
			end

			it "redirects to division#show from league_news" do
				get :handle_routes, league_news: nil, did: 1230
				response.should redirect_to(default_division_path(@division, :omp => :league_news))
			end

			it "redirects to division#show from league_notice" do
				get :handle_routes, league_notice: nil, did: 1230
				response.should redirect_to(default_division_path(@division, :omp => :league_notice))
			end

			it "redirects to division#show from league_info" do
				get :handle_routes, league_info: nil, did: 1230
				response.should redirect_to(default_division_path(@division, :omp => :league_info))
			end

		end	

	end
end