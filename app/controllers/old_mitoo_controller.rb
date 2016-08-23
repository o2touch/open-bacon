class OldMitooController < ApplicationController
  
  include TeamUrlHelper
  include DivisionUrlHelper

  def handle_routes

    # if chromeless
    if params[:chromeless]=='1'
      redirect_to "http://old.mitoo.co/" + request.fullpath and return
    end
    
    league_redirect = false

    # Team
    if !params[:mdbtid].nil?
      mdb_team_id = params[:mdbtid] 
      team = Team.find_by_mitoo_id(mdb_team_id)
    elsif !params[:tid].nil?
      gr_team_id = params[:tid]
      mdb_team_id = Mitoo::MitooTeam.get_mdbid_from_gid(gr_team_id)
      team = Team.find_by_mitoo_id(mdb_team_id)
    elsif !params[:fix_id].nil?      
    # Division
    elsif !params[:did].nil?  && !params[:did].empty?
      gr_division_id = params[:did]
      mdb_division_id = Mitoo::MitooDivision.get_mdbid_from_gid(gr_division_id)
      division = DivisionSeason.find_by_mitoo_id(mdb_division_id)

      league_redirect = true if (!params[:lid].nil?  && !params[:lid].empty?)
    end

    # Team Page
    unless team.nil?
      team_params = [:canvas, :fixtures, :team_fixtures, :results, :table, :stats, :news, :notice, :info, :followers]
      team_params.each do |p|
        redirect_to default_team_path(team, omp: p), :status => 301 and return if params.key?(p)
      end
    end

    # League Page
    unless division.nil?
      league_params = [:league, :league_results, :league_table, :league_fixtures, :league_news, :league_table, :league_notice, :league_info, :league_scorers]
      league_params.each do |p|

        if league_redirect
          redirect_to league_path(division.league, omp: p), :status => 301 and return if params.key?(p)
        else
          redirect_to default_division_path(division, omp: p), :status => 301 and return if params.key?(p)
        end
      end
    end

    # Don't know where to redirect to. Probably should log this
    redirect_to root_url
  end

  def redirect_fm_leagues
    fm_id = params[:id]

    league = League.find_by_source_id(fm_id)
    redirect_to league_path(league, omp: p), :status => 301 and return if !league.nil?

    # Don't know where to redirect to. Probably should log this
    redirect_to root_url
  end

end