class Tenants::RewardsAndRecognitionController < ApplicationController

  def show
    set_variables_and_authorize

    team_ids = Metrics::TeamAnalysis.tenant_team_ids(2)
    teams = Team.find(team_ids)

    @points = {
      teams: teams,
      dates: [],
      data: {}
    }

    start_date = Date.new(2014,6,1)
    end_date = Date.today

    (start_date..end_date).each do |date|
      next if date != date.at_beginning_of_month
      
      date_str = date.strftime("%Y-%m-%d")

      @points[:dates] << date_str
      @points[:data][date_str] = Metrics::RewardsAndRecognitionAnalysis.get_points_for_month(date)
    end

    render :layout => 'tenant_app'
  end

  def show_drilldown
    set_variables_and_authorize

    date = Date.new
    date = Date.strptime(params[:date], "%Y-%m-%d") unless params[:date].nil?

    @date = date
    @points = Metrics::RewardsAndRecognitionAnalysis.get_points_for_month(date)

    render :layout => 'tenant_app'
  end

  def attendance
    set_variables_and_authorize

    team_id = params[:team_id]
    date = Date.new(2014,6,1)
    date = Date.strptime(params[:date], "%Y-%m-%d") unless params[:date].nil?

    @attendance = Metrics::RewardsAndRecognitionAnalysis.get_player_attendance_for_month(team_id, date)

    cols = [:name, :gender, :experience]

    @attendance[:dates].each do |d|
      cols << d
    end

    @csv = CSV.generate do |csv|
      # titles
      csv << cols
    
      @attendance[:data].each do |k,d|
        puts d.to_yaml
        row = []
        row << d[:name]
        row << d[:gender]
        row << d[:experience]

        @attendance[:dates].each do |date|
           
           event_col = "NA"
          if !d[date].nil? && d[date]
            event_col = "Y"
          elsif !d[date].nil? && !d[date]
            event_col = "N"
          end

           row << event_col
        end

        csv << row
      end
    end
  
    respond_to do |format|
      # format.html { render 'teams_follows', :layout => "admin_webarch" }
      format.csv { render text: @csv, layout: false }
    end 

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