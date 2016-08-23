class Tenants::ReportsController < ApplicationController

  def show

    set_variables_and_authorize

    render 'show_overview', :layout => 'tenant_app'
  end

  def show_participation
    set_variables_and_authorize

    render :layout => 'tenant_app'
  end

  def show_engagement

    set_variables_and_authorize

    @total_players = 12000
    @total_players_change = 20

    @new_players = 12000
    @new_players_change = 20

    render :layout => 'tenant_app'
  end

  private

  def set_variables_and_authorize
    # tenant info
    @tenant = LandLord.new(params[:tenant_name]).tenant
    @tenant_json = Rabl.render(@tenant, 'api/v1/tenants/show', view_path: 'app/views',  formats: :json, locals: { page: "club" }).html_safe 

    # Check for permissions here
    authorize! :read_reports, @tenant

    # Get User, Teams and leagues for navigation
    if !current_user.nil?
      @current_user_teams_json = Rabl.render(current_user.teams, "api/v1/teams/index", view_path: 'app/views', :formats => [:json], :scope => @global_application_context, :handlers => [:rabl])
      @current_user_leagues_json = Rabl.render(current_user.leagues_as_organiser, "api/v1/leagues/index", view_path: 'app/views', :formats => [:json], :scope => @global_application_context, :handlers => [:rabl])
      @user_json = Rabl.render(current_user, "api/v1/users/show", view_path: 'app/views', :formats => [:json], :handlers => [:rabl])
    end
  end

end